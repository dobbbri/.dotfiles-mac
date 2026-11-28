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
        ;; Servidor do npm (`npm install -g --prefix ~/.local @tailwindcss/language-server',
        ;; feito pelo install.sh). Se não estiver no PATH, o caminho fica vazio e o lsp-mode
        ;; usa a instalação gerenciada (ver o fim deste arquivo).
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
;; Se o servidor do npm iniciar mas o log mostrar "Initialized 0 projects" e nada completar
;; (aconteceu em um teste anterior), desinstale-o e use o gerenciado pelo lsp-mode, que baixa
;; a extensão oficial do VS Code:
;;   npm uninstall -g --prefix ~/.local @tailwindcss/language-server
;;   M-x lsp-install-server RET tailwindcss   (precisa de node; reinstale com C-u)
(with-eval-after-load 'lsp-tailwindcss
  (dolist (mode '(astro-ts-mode css-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode)))

(provide 'init-lsp)
