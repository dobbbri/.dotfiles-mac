;;; config.el -*- lexical-binding: t; -*-

;;; ------------------------------------------------------------
;;; Aparência + ícones
;;; ------------------------------------------------------------
;; Rode uma vez: M-x nerd-icons-install-fonts
(setq doom-theme 'doom-tokyo-night
      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14 :weight 'medium)
      display-line-numbers-type 'relative
      doom-modeline-icon t
      doom-modeline-major-mode-icon t
      doom-modeline-buffer-file-name-style 'truncate-upto-project)

(after! treemacs
  (treemacs-load-theme "nerd-icons"))

;; Dashboard enxuta (mais rápido)
(setq +doom-dashboard-functions
      '(doom-dashboard-widget-banner
        doom-dashboard-widget-shortmenu
        doom-dashboard-widget-loaded))

;;; ------------------------------------------------------------
;;; Tree-sitter (Emacs 29+)
;;; ------------------------------------------------------------
(setq treesit-font-lock-level 4)

;; Repos que guardam mais de uma gramatica (typescript/tsx) precisam do 4o item
;; (subdiretorio com o src/); o padrao "src" falha com "repo/src: No such file".
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

;; Garante que nossas entradas vencem as de outros pacotes (treesit-auto etc.)
(after! treesit
  (dolist (e my/treesit-sources)
    (setf (alist-get (car e) treesit-language-source-alist) (cdr e))))

(defun my/treesit-install-all ()
  "Instala as gramaticas de `my/treesit-sources' (precisa de git e de um compilador C)."
  (interactive)
  (let ((treesit-language-source-alist my/treesit-sources))
    (dolist (lang (mapcar #'car my/treesit-sources))
      (message "Instalando gramatica: %s" lang)
      (treesit-install-language-grammar lang))))

;;; ------------------------------------------------------------
;;; Astro
;;; ------------------------------------------------------------
(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :init
  (add-hook 'astro-ts-mode-local-vars-hook #'lsp! 'append))

;;; ------------------------------------------------------------
;;; LSP (lsp-mode)
;;; ------------------------------------------------------------
(after! lsp-mode
  (setq lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil
        lsp-enable-folding nil
        lsp-enable-symbol-highlighting t
        lsp-signature-doc-lines 1
        lsp-file-watch-threshold 3000
        ;; eslint desativado: o lint fica com o Biome
        lsp-disabled-clients '(eslint))

  ;; astro-ls
  (add-to-list 'lsp-language-id-configuration '(astro-ts-mode . "astro"))
  (add-to-list 'lsp-language-id-configuration '("\\.astro\\'" . "astro"))

  ;; Não vigiar pastas pesadas
  (dolist (dir '("[/\\\\]node_modules\\'"
                 "[/\\\\]\\.astro\\'"
                 "[/\\\\]dist\\'"
                 "[/\\\\]\\.git\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories dir)))

(after! lsp-ui
  (setq lsp-ui-sideline-enable nil
        lsp-ui-doc-enable nil))

;; Tailwind CSS como add-on (roda junto com ts-ls, html-ls, css-ls, astro-ls)
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init
  (setq lsp-tailwindcss-add-on-mode t)
  :config
  (add-to-list 'lsp-tailwindcss-major-modes 'astro-ts-mode))

;;; ------------------------------------------------------------
;;; Lint: Biome via LSP (diagnósticos + code actions)
;;; ------------------------------------------------------------
;; O servidor é `biome lsp-proxy', já incluso no pacote @biomejs/biome.
;; Os diagnósticos chegam pelo lsp-mode/flycheck, sem checker extra.
(defun my/biome-fix ()
  "Roda `biome check --write' (lint com fix seguro + formatação + imports) no arquivo."
  (interactive)
  (when buffer-file-name
    (save-buffer)
    (let ((out (get-buffer-create "*biome*")))
      (call-process "biome" nil out nil "check" "--write" buffer-file-name)
      (revert-buffer t t t)
      (message "biome check --write concluído"))))

(map! :leader :desc "Biome check --write" "c z" #'my/biome-fix)

;;; ------------------------------------------------------------
;;; Formatação (apheleia): biome se o projeto tiver biome.json, senão prettierd
;;; ------------------------------------------------------------
(set-formatter! 'biome
  '("biome" "format" "--stdin-file-path" filepath))

(set-formatter! 'prettierd
  '("prettierd" filepath)
  :modes '(html-mode mhtml-mode web-mode html-ts-mode astro-ts-mode
           css-mode css-ts-mode scss-mode
           js-mode js-ts-mode js2-mode typescript-mode typescript-ts-mode
           tsx-ts-mode json-mode json-ts-mode markdown-mode))

(set-formatter! 'shfmt
  '("shfmt" "-i" "2" "-ci" "-filename" filepath)
  :modes '(sh-mode bash-ts-mode))

(defun my/project-uses-biome-p ()
  (locate-dominating-file
   default-directory
   (lambda (dir)
     (or (file-exists-p (expand-file-name "biome.json" dir))
         (file-exists-p (expand-file-name "biome.jsonc" dir))))))

(defun my/pick-formatter-h ()
  "Em projetos com biome.json, usa Biome para JS/TS/JSON/CSS/HTML/Astro.
HTML e Astro dependem do suporte experimental do Biome (veja biome.json)."
  (when (and (derived-mode-p 'js-mode 'js-ts-mode 'js2-mode 'typescript-mode
                             'typescript-ts-mode 'tsx-ts-mode 'json-mode
                             'json-ts-mode 'css-mode 'css-ts-mode 'scss-mode
                             'html-mode 'mhtml-mode 'web-mode 'html-ts-mode
                             'astro-ts-mode)
             (my/project-uses-biome-p))
    (setq-local apheleia-formatter 'biome)))
(add-hook 'apheleia-mode-hook #'my/pick-formatter-h)
