;;; +lsp.el -*- lexical-binding: t; -*-

;; lsp-mode (módulo `lsp' do Doom): astro-ls, Tailwind e Biome rodam juntos em
;; arquivos .astro; o TypeScript fica por conta do astro-ls.

(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :init (add-hook 'astro-ts-mode-hook #'lsp! 'append))

(setq lsp-auto-guess-root t              ; sem isso o astro-ls não acha o typescript do projeto
      lsp-lens-enable nil
      lsp-headerline-breadcrumb-enable nil
      lsp-enable-on-type-formatting nil
      +format-with-lsp nil)              ; quem formata é o Biome (Apheleia), nunca o LSP

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  ;; Não vigiar pastas geradas (o maior custo do lsp-mode em projetos Node).
  (dolist (re '("[/\\\\]\\.astro\\'" "[/\\\\]dist\\'" "[/\\\\]\\.vercel\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re)))

;; Tailwind CSS como add-on, junto dos outros servidores.
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init (setq lsp-tailwindcss-add-on-mode t
              ;; O padrão do pacote (0.14.7) é anterior ao Tailwind v4.3; a 0.16
              ;; corrige os avisos falsos de conflito de CSS a partir da v4.3.3.
              lsp-tailwindcss-server-version "0.16.0")
  :config
  (dolist (mode '(astro-ts-mode css-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode)))
