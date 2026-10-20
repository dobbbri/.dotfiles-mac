;;; config.el -*- lexical-binding: t; -*-

;;; ============================================================
;;; Aparência e editor
;;; ============================================================
;; Rode uma vez: M-x nerd-icons-install-fonts
(setq doom-theme 'doom-tokyo-night
      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14 :weight 'medium)
      display-line-numbers-type 'relative
      doom-modeline-icon t
      doom-modeline-major-mode-icon t
      doom-modeline-buffer-file-name-style 'truncate-upto-project)

;; Prettier (useTabs: true) grava TABs: mostra com 2 colunas (= tabWidth)
(setq-default tab-width 2)

(after! treemacs
  (treemacs-load-theme "nerd-icons"))

(setq +doom-dashboard-functions
      '(doom-dashboard-widget-banner
        doom-dashboard-widget-shortmenu
        doom-dashboard-widget-loaded))

;;; ============================================================
;;; Tree-sitter
;;; ============================================================
;; Nivel 3 (padrao): o 4 e bem mais caro, principalmente em .astro
(setq treesit-font-lock-level 3)

;; typescript e tsx moram no mesmo repo, em subpastas: o 4o item e obrigatorio
(defvar my/treesit-sources
  '((astro      "https://github.com/virchau13/tree-sitter-astro")
    (bash       "https://github.com/tree-sitter/tree-sitter-bash")
    (css        "https://github.com/tree-sitter/tree-sitter-css")
    (html       "https://github.com/tree-sitter/tree-sitter-html")
    (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
    (json       "https://github.com/tree-sitter/tree-sitter-json")
    (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
    (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
  "Fontes das gramaticas tree-sitter usadas nesta config.")

;; Nossas entradas vencem as de outros pacotes (treesit-auto etc.)
(after! treesit
  (dolist (e my/treesit-sources)
    (setf (alist-get (car e) treesit-language-source-alist) (cdr e))))

(defun my/treesit-install-all ()
  "Instala as gramaticas de `my/treesit-sources' (precisa de git e compilador C)."
  (interactive)
  (let ((treesit-language-source-alist my/treesit-sources))
    (dolist (lang (mapcar #'car my/treesit-sources))
      (message "Instalando gramatica: %s" lang)
      (treesit-install-language-grammar lang))))

;;; ============================================================
;;; Astro
;;; ============================================================
;; Sem autoloads do pacote (veja packages.el): o :mode cria o autoload do modo.
(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :init
  (add-hook 'astro-ts-mode-local-vars-hook #'lsp! 'append))

;;; ============================================================
;;; LSP (lsp-mode)
;;;   servidores : ts-ls, astro-ls, html-ls, css-ls, json-ls, bash-ls
;;;   add-on     : tailwindcss (roda junto, inclusive em .astro)
;;;   diagnostico: LSP -> flycheck
;;;   formatacao : NUNCA pelo LSP (veja a secao seguinte)
;;; ============================================================
(after! lsp-mode
  (setq lsp-log-io nil
        lsp-keep-workspace-alive nil
        lsp-idle-delay 0.5
        ;; menos requisicoes e menos UI
        lsp-enable-symbol-highlighting nil
        lsp-enable-folding nil
        lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil
        lsp-modeline-code-actions-enable nil
        lsp-signature-auto-activate nil
        lsp-inlay-hint-enable nil
        lsp-semantic-tokens-enable nil
        ;; o LSP nao formata (astro-ls/ts-ls ignoram o prettier.config.js)
        lsp-before-save-edits nil
        lsp-enable-on-type-formatting nil
        lsp-enable-indentation nil
        lsp-enable-relative-indentation nil
        ;; file watchers
        lsp-file-watch-threshold 3000)

  (setq read-process-output-max (* 3 1024 1024))

  (dolist (re '("[/\\\\]node_modules\\'"
                "[/\\\\]\\.astro\\'"
                "[/\\\\]dist\\'"
                "[/\\\\]\\.git\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re))

  ;; astro-ls
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  (add-to-list 'lsp-language-id-configuration '("\\.astro\\'" . "astro")))

;; Tailwind CSS como add-on
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init
  (setq lsp-tailwindcss-add-on-mode t)
  :config
  (add-to-list 'lsp-tailwindcss-major-modes 'astro-ts-mode))

;;; ============================================================
;;; Formatação (apheleia): prettierd (web) e shfmt (shell)
;;; ============================================================
(setq +format-with-lsp nil)

(set-formatter! 'prettierd
  '("prettierd" filepath)
  :modes '(html-mode mhtml-mode web-mode html-ts-mode astro-ts-mode
           css-mode css-ts-mode scss-mode
           js-mode js-ts-mode js2-mode typescript-mode typescript-ts-mode
           tsx-ts-mode json-mode json-ts-mode markdown-mode))

(set-formatter! 'shfmt
  '("shfmt" "-i" "2" "-ci" "-filename" filepath)
  :modes '(sh-mode bash-ts-mode))
