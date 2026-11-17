;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; 1. Integração com caminhos do MacPorts
;; (o `doom sync --env` já captura o PATH do shell; isto garante o GUI mesmo assim)
(add-to-list 'exec-path "/opt/local/bin")
(setenv "PATH" (concat "/opt/local/bin:" (getenv "PATH")))

;; 2. (removido) gc-cons-threshold: o Doom já gerencia o GC via gcmh,
;;    e sobrescrever aqui só atrapalha.

;; 3. Ajustes de teclado para macOS (emacs-app do MacPorts usa as variáveis ns-*)
(setq mac-command-modifier 'super
      ns-command-modifier  'super
      mac-option-modifier  'meta
      ns-option-modifier   'meta)

;; 4. Tema Visual: Catppuccin (Sabores: 'mocha, 'macchiato, 'frappe, 'latte)
(setq catppuccin-flavor 'mocha)
(setq doom-theme 'catppuccin)

;; 5. Tree-sitter nativo (Emacs 31.1)
;; Todas as gramáticas (astro, bash, css, html, js, json, yaml, ts, tsx) são
;; compiladas pelo build-grammars.sh e ficam em ~/.local/lib/tree-sitter
(add-to-list 'treesit-extra-load-path (expand-file-name "~/.local/lib/tree-sitter"))
(setopt treesit-auto-install-grammar 'ask
        treesit-enabled-modes '(typescript-ts-mode tsx-ts-mode js-ts-mode
                                css-ts-mode mhtml-ts-mode json-ts-mode
                                yaml-ts-mode bash-ts-mode))

(with-eval-after-load 'treesit
  (unless (assq 'astro treesit-language-source-alist)
    (add-to-list 'treesit-language-source-alist
                 '(astro "https://github.com/virchau13/tree-sitter-astro" "master" "src"))))

;; 6. LSP com lsp-mode (módulo `lsp' do Doom, sem +eglot)
;; Ao contrário do Eglot, o lsp-mode roda vários servidores no mesmo buffer
;; (tsserver + astro-ls + Tailwind em arquivos .astro).
;; Ajustes leves para 8 GB de RAM:
(setq lsp-idle-delay 0.5
      lsp-lens-enable nil
      lsp-headerline-breadcrumb-enable nil)

;; Sem ESLint: o lsp-mode não deve tentar o cliente dele.
(after! lsp-mode
  (add-to-list 'lsp-disabled-clients 'eslint))

;; 6.1 Astro: astro-ts-mode + astro-ls
(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :init (add-hook 'astro-ts-mode-hook #'lsp! 'append))

;; O astro-ls exige `typescript.tsdk': usa o TypeScript do projeto
;; (node_modules/typescript/lib) ou, na falta dele, o global (npm root -g).
(defun my/astro-tsdk ()
  "Devolve o diretório lib do TypeScript para o astro-ls."
  (let ((local (locate-dominating-file default-directory
                                       "node_modules/typescript/lib")))
    (if local
        (expand-file-name "node_modules/typescript/lib" local)
      (expand-file-name
       "typescript/lib"
       (string-trim (shell-command-to-string "npm root -g"))))))

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("astro-ls" "--stdio"))
    :activation-fn (lsp-activate-on "astro")
    :initialization-options (lambda () `(:typescript (:tsdk ,(my/astro-tsdk))))
    :priority 1
    :server-id 'my-astro-ls)))

;; 6.2 Tailwind CSS: add-on, convive com astro-ls e tsserver no mesmo buffer.
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init (setq lsp-tailwindcss-add-on-mode t)
  :config
  (dolist (mode '(astro-ts-mode tsx-ts-mode css-ts-mode mhtml-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode)))

;; 7. BiomeJS no lugar de Prettier e ESLint
;; O Biome lê o biome.json do projeto (tabs, aspas duplas, regras de lint) e
;; usa o binário de node_modules/.bin quando existe; senão, o global.
;; Formatação ao salvar: Apheleia (módulo `format +onsave').
;; Lint, diagnósticos e code actions: lsp-biome (cliente do lsp-mode que roda
;; `biome lsp-proxy' como add-on, junto dos outros servidores).
(defconst my/biome-modos
  '(astro-ts-mode js-mode js-ts-mode typescript-mode typescript-ts-mode
    tsx-ts-mode json-mode json-ts-mode css-mode css-ts-mode)
  "Major modes cujos arquivos são formatados pelo Biome.")

(defun my/biome-config-p ()
  "Não-nil se existe biome.json ou biome.jsonc acima do arquivo atual."
  (and buffer-file-name
       (or (locate-dominating-file buffer-file-name "biome.json")
           (locate-dominating-file buffer-file-name "biome.jsonc"))))

(defun my/biome-sem-config-p (&rest _)
  "Não-nil quando o Biome NÃO deve rodar: modo suportado, mas sem biome.json.
Evita reformatar com os padrões do Biome projetos que não o usam."
  (and (apply #'derived-mode-p my/biome-modos)
       (not (my/biome-config-p))))

(after! apheleia
  ;; Ao salvar: só formatação.
  (setf (alist-get 'biome apheleia-formatters)
        '("apheleia-npx" "biome" "format" "--stdin-file-path" filepath))
  (dolist (mode my/biome-modos)
    (setf (alist-get mode apheleia-mode-alist) 'biome))
  ;; O Biome não formata YAML nem HTML (com o seu biome.json): remove o
  ;; Prettier que o Doom usaria por padrão nesses modos.
  (dolist (mode '(yaml-mode yaml-ts-mode html-mode html-ts-mode mhtml-mode
                  mhtml-ts-mode web-mode))
    (setf (alist-get mode apheleia-mode-alist nil 'remove) nil))
  (add-hook 'apheleia-inhibit-functions #'my/biome-sem-config-p))

;; Sem ESLint: o Flycheck não deve tentar o checker dele.
(after! flycheck
  (add-to-list 'flycheck-disabled-checkers 'javascript-eslint))

(defun my/biome-lint-projeto ()
  "Roda `biome lint' no projeto e lista os problemas num buffer de compilação."
  (interactive)
  (let ((default-directory (if-let* ((proj (project-current)))
                               (project-root proj)
                             default-directory)))
    (compile "npx --no-install biome lint --colors=off --max-diagnostics=200 .")))

(map! :leader
      :desc "Biome: corrigir tudo"        "c B" #'lsp-biome-fix-all
      :desc "Biome: organizar imports"    "c O" #'lsp-biome-organize-imports
      :desc "Biome: lint do projeto"      "c L" #'my/biome-lint-projeto)

;; lsp-biome: só ativa em projetos com biome.json e usa o Biome do projeto
;; (node_modules/@biomejs/biome) ou, na falta dele, o do PATH.
;; Inclui `.astro' nos tipos de arquivo (o padrão do pacote não inclui).
(use-package! lsp-biome
  :after lsp-mode
  :config
  (setq lsp-biome-active-file-types
        (list (rx "." (or "tsx" "jsx" "ts" "js" "mts" "mjs" "cts" "cjs"
                          "json" "jsonc" "css" "astro")
                  eos))))

;; 8. Configuração Personalizada do Org-mode
(setq org-directory "~/org/"
      org-default-notes-file (expand-file-name "inbox.org" org-directory)
      org-agenda-files (list org-directory (expand-file-name "daily" org-directory))
      org-log-done 'time)

(after! org
  ;; Templates de Captura Rápida (Acionados via SPC X)
  (setq org-capture-templates
        '(("t" "Tarefa Rápida (Inbox)" entry
           (file+headline "~/org/inbox.org" "Tarefas")
           "* TODO %?\n  Criada em: %U\n  %a")

          ("d" "Diário / Nota de Hoje" entry
           (file+olp+datetree "~/org/daily/diario.org")
           "* %<%H:%M> - %?\n")

          ("p" "Ideia de Projeto / Código" entry
           (file+headline "~/org/projetos.org" "Backlog Dev")
           "* TODO %? :dev:\n  %U\n"))))

;; Atalhos personalizados de produtividade (SPC n ...)
(map! :leader
      (:prefix ("n" . "notes/org")
       :desc "Abrir Inbox Org"  "i" (cmd! (find-file "~/org/inbox.org"))
       :desc "Abrir Diário Org" "d" (cmd! (find-file "~/org/daily/diario.org"))
       :desc "Agenda de Hoje"   "a" #'org-agenda-list
       :desc "Lista de TODOs"   "t" #'org-todo-list))
