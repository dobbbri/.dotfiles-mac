;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; 1. Integração com caminhos do MacPorts
(add-to-list 'exec-path "/opt/local/bin")
(setenv "PATH" (concat "/opt/local/bin:" (getenv "PATH")))

;; 2. Otimização de memória (Garbage Collection) para 8GB RAM
(setq gc-cons-threshold (* 50 1000 1000))

;; 3. Ajustes de teclado para macOS
(setq mac-command-modifier 'super
      mac-option-modifier 'meta)

;; 4. Tema Visual: Catppuccin (Sabores: 'mocha, 'macchiato, 'frappe, 'latte)
(setq catppuccin-flavor 'mocha)
(setq doom-theme 'catppuccin)

;; 5. Carregar gramáticas do MacPorts + Fontes para M-x treesit-install-language-grammar
(add-to-list 'treesit-extra-load-path "/opt/local/lib")

(setq treesit-language-source-alist
      '((astro      "https://github.com")
        (css        "https://github.com")
        (html       "https://github.com")
        (javascript "https://github.com" "master" "src")
        (json       "https://github.com")
        (tsx        "https://github.com" "master" "tsx/src")
        (typescript "https://github.com" "master" "typescript/src")))

;; 6. Suporte Nativo ao Astro (astro-ts-mode) e Tailwind CSS via Eglot
(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :hook (astro-ts-mode . eglot-ensure))

(with-eval-after-load 'eglot
  ;; Servidor LSP do Astro apontando para o TypeScript 6 do MacPorts
  (add-to-list 'eglot-server-programs
               '(astro-ts-mode . ("astro-ls" "--stdio"
                                  :initializationOptions
                                  (:typescript (:tsdk "/opt/local/lib/node_modules/typescript/lib")))))

  ;; Servidor LSP do Tailwind CSS para Astro, React (TSX) e HTML
  (add-to-list 'eglot-server-programs
               '((astro-ts-mode tsx-ts-mode html-mode) . ("tailwindcss-language-server" "--stdio"))))

;; 7. BiomeJS: Formatação ao salvar (Apheleia) + Linting em tempo real (Flycheck + Eglot)
(after! apheleia
  (setf (alist-get 'biome apheleia-formatters)
        '("biome" "format" "--stdin-file-path" filepath))
  (dolist (mode '(js-mode js-ts-mode typescript-mode typescript-ts-mode tsx-ts-mode astro-ts-mode web-mode json-mode))
    (setf (alist-get mode apheleia-mode-alist) 'biome)))

(use-package! flycheck-biomejs
  :after (flycheck eglot)
  :config
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'js-mode 'js-ts-mode 'typescript-mode 'typescript-ts-mode 'tsx-ts-mode 'json-mode)
                (flycheck-add-next-checker 'eglot-check 'javascript-biomejs)))))

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
           "* TODO %? :dev:\n  %U\n")))

  ;; Atalhos personalizados de produtividade (SPC n ...)
  (map! :leader
        (:prefix ("n" . "notes/org")
         :desc "Abrir Inbox Org"        "i" (cmd! (find-file "~/org/inbox.org"))
         :desc "Abrir Diário Org"       "d" (cmd! (find-file "~/org/daily/diario.org"))
         :desc "Agenda de Hoje"         "a" #'org-agenda-list
         :desc "Lista de TODOs"         "t" #'org-todo-list)))
