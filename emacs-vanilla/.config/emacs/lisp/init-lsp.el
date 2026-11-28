;;; init-lsp.el -*- lexical-binding: t; -*-

;; lsp-mode: astro-ls, Tailwind e Biome rodam juntos em arquivos .astro; o
;; TypeScript fica por conta do astro-ls.

(use-package astro-ts-mode
  :commands astro-ts-mode)               ; a associação do .astro fica em init-treesit.el

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-auto-guess-root t                 ; sem isso o astro-ls não acha o typescript do projeto
        lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil
        lsp-enable-on-type-formatting nil     ; quem formata é o Biome (Apheleia), nunca o LSP
        lsp-enable-indentation nil
        lsp-enable-folding nil
        lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-completion-provider :capf
        lsp-tailwindcss-add-on-mode t         ; Tailwind (cliente embutido) roda junto dos outros;
                                              ; precisa ser definido antes de o cliente carregar
        ;; Tailwind v4 não tem tailwind.config.*; sem isto o cliente nem ativa.
        lsp-tailwindcss-skip-config-check t
        ;; Por padrão o servidor é o gerenciado pelo lsp-mode (baixado na primeira abertura,
        ;; ver `my/lsp-install-missing' abaixo). Se houver um `tailwindcss-language-server'
        ;; do npm no PATH, ele tem prioridade (nenhum é instalado por padrão).
        lsp-tailwindcss-server-path (or (executable-find "tailwindcss-language-server") "")
        ;; Só vale para a instalação gerenciada: o padrão (0.14.7) é anterior ao Tailwind
        ;; v4.3; a 0.16 corrige os avisos falsos de conflito de CSS a partir da v4.3.3.
        lsp-tailwindcss-server-version "0.16.0"
        lsp-session-file (expand-file-name "lsp-session-v1" my/var-dir)
        lsp-server-install-dir (expand-file-name "lsp-servers/" my/var-dir))
  :hook (((astro-ts-mode js-ts-mode typescript-ts-mode tsx-ts-mode
           json-ts-mode css-ts-mode html-ts-mode)
          . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . (lambda () (setq-local evil-lookup-func #'lsp-describe-thing-at-point))))  ; K = doc via LSP
  :config
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  ;; Não vigiar pastas geradas (o maior custo do lsp-mode em projetos Node).
  (dolist (re '("[/\\\\]\\.astro\\'" "[/\\\\]dist\\'" "[/\\\\]\\.vercel\\'"
                "[/\\\\]node_modules\\'" "[/\\\\]\\.git\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re))
  ;; Quem lint é o Biome, não o ESLint.
  (add-to-list 'lsp-disabled-clients 'eslint))

;; O cliente de Tailwind já vem no lsp-mode; só acrescenta os modos que ele não cobre.
(with-eval-after-load 'lsp-tailwindcss
  (dolist (mode '(astro-ts-mode css-ts-mode html-ts-mode js-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode))

  ;; O servidor do Tailwind só declara `completionProvider' quando o cliente NÃO aceita
  ;; registro dinâmico; o lsp-mode aceita, então ele vem vazio, e o ajuste do "-" do
  ;; cliente (`lsp-tailwindcss--company-dash-hack') faz (lsp-put nil ...) e dá "Error
  ;; processing message (wrong-type-argument hash-table-p nil)". Esse erro interrompe a
  ;; inicialização: o buffer que iniciou o servidor nunca é aberto nele (sem completar
  ;; nem cores) e o "initialized successfully" do Tailwind não aparece. Aqui o erro é
  ;; ignorado e a inicialização segue.
  (advice-add 'lsp-tailwindcss--company-dash-hack :around
              (lambda (fn workspace)
                (condition-case nil (funcall fn workspace) (error nil)))))

;; --- Instalação antecipada dos servidores (estilo Mason) -------------------------------
;; 5 s depois de o Emacs abrir, os servidores que faltarem são instalados, sem ação sua.
;; Precisa de internet e de `node'/`npm' no PATH (o install.sh instala o Node via nvm).
;;  - npm: astro-ls, typescript-language-server (+ typescript), json/css/html (vscode-
;;    langservers-extracted) e Biome, em ~/.local/bin, onde o lsp-mode os acha pelo PATH.
;;  - Tailwind: o gerenciado pelo lsp-mode (extensão oficial do VS Code), em var/lsp-servers/.
;; O Biome de cada projeto (node_modules) continua tendo prioridade sobre o global.
(defconst my/lsp-npm-servers
  '(("astro-ls"                    . "@astrojs/language-server")
    ("typescript-language-server"  . "typescript-language-server")
    ("tsc"                         . "typescript@6")
    ("vscode-json-language-server" . "vscode-langservers-extracted")
    ("biome"                       . "@biomejs/biome"))
  "Servidores instalados via npm: (EXECUTÁVEL . PACOTE).")

(defun my/lsp-install-npm-missing ()
  "Instala em ~/.local, via npm, os servidores de `my/lsp-npm-servers' que faltarem."
  (interactive)
  (let ((pkgs (cl-loop for (exe . pkg) in my/lsp-npm-servers
                       unless (executable-find exe) collect pkg))
        (npm (executable-find "npm")))
    (cond
     ((null pkgs) nil)
     ((not npm) (message "lsp: npm não encontrado; instale o Node (nvm) e use M-x my/lsp-install-missing."))
     (t
      (message "lsp: instalando via npm: %s..." (string-join pkgs ", "))
      (make-process
       :name "lsp-npm-install"
       :buffer (get-buffer-create "*lsp-npm-install*")
       :noquery t
       :command `(,npm "install" "-g" "--prefix" ,(expand-file-name "~/.local") ,@pkgs)
       :sentinel (lambda (proc _event)
                   (when (memq (process-status proc) '(exit signal))
                     (if (zerop (process-exit-status proc))
                         (message "lsp: servidores npm instalados.")
                       (message "lsp: o npm falhou (código %d); veja *lsp-npm-install*."
                                (process-exit-status proc))))))))))

(defun my/lsp-install-tailwind-missing ()
  "Baixa o servidor Tailwind gerenciado pelo `lsp-mode' se ainda não estiver instalado."
  (interactive)
  (if (not (executable-find "node"))
      (message "lsp: node não encontrado; servidor Tailwind não instalado.")
    (require 'lsp-mode)
    (require 'lsp-tailwindcss)
    (unless (or (not (string-empty-p lsp-tailwindcss-server-path)) ; usando o do npm
                (file-exists-p (lsp-tailwindcss-server-command)))
      (message "lsp: baixando o servidor Tailwind...")
      (lsp-install-server nil 'tailwindcss))))

(defun my/lsp-install-missing ()
  "Instala todos os servidores LSP que a config usa e que ainda faltarem."
  (interactive)
  (my/lsp-install-npm-missing)
  (my/lsp-install-tailwind-missing))

(unless noninteractive
  (add-hook 'emacs-startup-hook
            (lambda () (run-with-idle-timer 5 nil #'my/lsp-install-missing))))

(provide 'init-lsp)
