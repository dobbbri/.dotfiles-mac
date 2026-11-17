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

;; 6. Suporte ao Astro (astro-ts-mode) via Eglot
(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :hook (astro-ts-mode . eglot-ensure))

;; Servidor LSP do Astro. O tsdk é resolvido na hora de iniciar o servidor:
;; 1) typescript do projeto (node_modules/typescript/lib); 2) typescript global (npm root -g).
(defun my/astro-ls-contact (&rest _)
  (let* ((local (locate-dominating-file default-directory "node_modules/typescript/lib"))
         (global (expand-file-name
                  "typescript/lib"
                  (string-trim (shell-command-to-string "npm root -g"))))
         (tsdk (if local
                   (expand-file-name "node_modules/typescript/lib" local)
                 global)))
    `("astro-ls" "--stdio"
      :initializationOptions (:typescript (:tsdk ,tsdk)))))

(after! eglot
  (add-to-list 'eglot-server-programs
               '(astro-ts-mode . my/astro-ls-contact)))

;; OBS: o Eglot usa UM servidor por buffer. A entrada antiga do Tailwind para
;; (astro-ts-mode tsx-ts-mode html-mode) sobrescrevia o astro-ls e o
;; typescript-language-server do TSX, quebrando o LSP. Foi removida.
;; Para Astro + Tailwind juntos, use o multiplexador `rass` do Eglot (Emacs 31).

;; 7. BiomeJS: formatação ao salvar (Apheleia) + linting (Flycheck + Eglot)
(after! apheleia
  (setf (alist-get 'biome apheleia-formatters)
        '("biome" "format" "--stdin-file-path" filepath))
  (dolist (mode '(js-mode js-ts-mode typescript-mode typescript-ts-mode
                  tsx-ts-mode json-mode json-ts-mode css-ts-mode))
    (setf (alist-get mode apheleia-mode-alist) 'biome)))

(defun my/biome-chain-checker ()
  "Encadeia o checker do Biome depois do eglot-check em buffers JS/TS/JSON."
  (when (and (derived-mode-p 'js-base-mode 'typescript-ts-base-mode 'json-ts-mode 'json-mode)
             (flycheck-valid-checker-p 'eglot-check)
             (flycheck-valid-checker-p 'javascript-biomejs))
    (flycheck-add-next-checker 'eglot-check 'javascript-biomejs)))

(use-package! flycheck-biomejs
  :after flycheck
  :config
  (add-hook 'eglot-managed-mode-hook #'my/biome-chain-checker))

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
