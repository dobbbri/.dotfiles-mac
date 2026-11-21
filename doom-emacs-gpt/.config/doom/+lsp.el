;;; +lsp.el -*- lexical-binding: t; -*-

;; lsp-mode (módulo `lsp' do Doom, sem +eglot): roda vários servidores no mesmo
;; buffer (astro-ls + Tailwind + Biome em arquivos .astro; o TypeScript fica
;; por conta do próprio astro-ls, que usa o typescript do projeto).

(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :init (add-hook 'astro-ts-mode-hook #'lsp! 'append))

;; Leve para 8 GB de RAM
(setq lsp-idle-delay 0.5
      lsp-lens-enable nil
      lsp-headerline-breadcrumb-enable nil
      lsp-enable-on-type-formatting nil)

;; Raiz do projeto: sem isso o lsp-mode pergunta a cada pasta nova e, se você
;; escolher "diretório atual" (.), o astro-ls procura node_modules/typescript
;; dentro da subpasta do arquivo e avisa "Unable to find typescript server path".
(setq lsp-auto-guess-root t)

;; Quem formata é o Biome (Apheleia), nunca o LSP: tsserver e Biome formatando
;; ao mesmo tempo brigariam a cada salvamento.
(setq +format-with-lsp nil)

(after! lsp-mode
  ;; O cliente `astro-ls' do lsp-mode só precisa saber que astro-ts-mode é "astro".
  ;; Ele lê o TypeScript de <projeto>/node_modules/typescript/lib.
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  ;; Não vigiar pastas geradas (o maior custo do lsp-mode em projetos Node).
  (dolist (re '("[/\\\\]\\.astro\\'" "[/\\\\]dist\\'" "[/\\\\]\\.vercel\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re)))

;; Tailwind CSS: add-on, convive com os outros servidores no mesmo buffer.
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init (setq lsp-tailwindcss-add-on-mode t)
  :config
  (dolist (mode '(astro-ts-mode tsx-ts-mode css-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode)))
