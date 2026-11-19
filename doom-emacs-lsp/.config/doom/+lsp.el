;;; +lsp.el -*- lexical-binding: t; -*-

;; LSP com lsp-mode (módulo `lsp' do Doom, sem +eglot)
;; Ao contrário do Eglot, o lsp-mode roda vários servidores no mesmo buffer
;; (tsserver + astro-ls + Tailwind + Biome em arquivos .astro).

(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :init (add-hook 'astro-ts-mode-hook #'lsp! 'append))

;; Ajustes leves para 8 GB de RAM
(setq lsp-idle-delay 0.5
      lsp-lens-enable nil
      lsp-headerline-breadcrumb-enable nil
      lsp-enable-on-type-formatting nil)

;; Formatação: sempre pelo Biome via Apheleia, nunca pelo formatador do LSP
;; (tsserver e Biome formatando ao mesmo tempo brigariam a cada salvamento).
(setq +format-with-lsp nil)

;; O astro-ls exige `typescript.tsdk': usa o TypeScript do projeto
;; (node_modules/typescript/lib); na falta dele, o global do install.sh
;; (~/.local/lib/node_modules); por último, o `npm root -g'.
(defvar my/npm-root-global nil
  "Cache de `npm root -g' (evita rodar o npm a cada abertura de arquivo .astro).")

(defun my/astro-tsdk ()
  "Devolve o diretório lib do TypeScript para o astro-ls."
  (let ((local (locate-dominating-file default-directory
                                       "node_modules/typescript/lib"))
        (global (expand-file-name "~/.local/lib/node_modules/typescript/lib")))
    (cond
     (local (expand-file-name "node_modules/typescript/lib" local))
     ((file-directory-p global) global)
     (t (expand-file-name
         "typescript/lib"
         (or my/npm-root-global
             (setq my/npm-root-global
                   (string-trim (shell-command-to-string "npm root -g")))))))))

(after! lsp-mode
  ;; Não vigiar pastas geradas: os file watchers são o maior custo do
  ;; lsp-mode em projetos Node (node_modules já vem ignorado por padrão).
  (dolist (re '("[/\\\\]\\.astro\\'" "[/\\\\]dist\\'"
                "[/\\\\]\\.vercel\\'" "[/\\\\]\\.next\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re))
  ;; astro-ls no lugar do cliente embutido (que não tem o TypeScript global).
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("astro-ls" "--stdio"))
    :activation-fn (lsp-activate-on "astro")
    :initialization-options (lambda () `(:typescript (:tsdk ,(my/astro-tsdk))))
    :priority 1
    :server-id 'my-astro-ls)))

;; Tailwind CSS: add-on, convive com astro-ls e tsserver no mesmo buffer.
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init (setq lsp-tailwindcss-add-on-mode t)
  :config
  (dolist (mode '(astro-ts-mode tsx-ts-mode css-ts-mode mhtml-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode)))
