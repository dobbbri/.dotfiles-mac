;;; config.el -*- lexical-binding: t; -*-

;;; Aparência

(setq doom-font
      (font-spec :family "Lekton Nerd Font Mono" :height 180 :weight 'regular)
      doom-theme 'catppuccin
      catppuccin-flavor 'mocha
      display-line-numbers-type 'relative)

;;; Desempenho — valores moderados para máquina com 8 GB de RAM.

(setq gc-cons-threshold (* 64 1024 1024)
      read-process-output-max (* 1024 1024)
      lsp-idle-delay 0.5)

;;; Tree-sitter

(after! treesit
  (setq treesit-language-source-alist
        '((astro "https://github.com/virchau13/tree-sitter-astro")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
               "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                      "master" "typescript/src"))))

;; Use os modos Tree-sitter nativos do Emacs 31 para JS/TS/TSX, JSON e CSS.
(add-to-list 'major-mode-remap-alist '(js-mode . js-ts-mode))
(add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode))
(add-to-list 'major-mode-remap-alist '(json-mode . json-ts-mode))
(add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

;;; Astro

(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :hook (astro-ts-mode . lsp-deferred)
  :config
  (setq astro-ts-mode-indent-offset 2))

;;; LSP

(after! lsp-mode
  (setq lsp-keymap-prefix "C-c l"
        lsp-auto-guess-root t
        lsp-completion-provider :capf
        lsp-enable-snippet t
        lsp-headerline-breadcrumb-enable nil
        lsp-signature-auto-activate '(:on-trigger-char :on-server-request))

  ;; O cliente lsp-biome abaixo substitui o cliente homônimo distribuído
  ;; com lsp-mode: ele inicia a versão local do projeto por `biome lsp-proxy`.
  (setq lsp-client-packages (remove 'lsp-biome lsp-client-packages)))

(use-package! lsp-biome
  :after lsp-mode
  :config
  (setq lsp-biome-add-on-mode t))

;; O cliente LSP do Tailwind vem integrado ao lsp-mode. Ele deve ser add-on
;; para coexistir com TypeScript e Astro no mesmo buffer.
(after! lsp-tailwindcss
  (setq lsp-tailwindcss-add-on-mode t)
  (add-to-list 'lsp-tailwindcss-major-modes 'astro-ts-mode))

;; Alguns modos nativos Tree-sitter não são iniciados automaticamente pelo
;; módulo javascript do Doom; estes hooks cobrem JS, TS, TSX, JSON, CSS e HTML.
(dolist (hook '(js-ts-mode-hook
                typescript-ts-mode-hook
                tsx-ts-mode-hook
                json-ts-mode-hook
                css-ts-mode-hook
                html-ts-mode-hook))
  (add-hook hook #'lsp-deferred))

;;; Biome + Apheleia

(after! apheleia
  ;; Usa o Biome instalado localmente no projeto. O argumento filepath
  ;; informa a extensão real ao formatador via stdin.
  (setf (alist-get 'biome apheleia-formatters)
        '("npx" "--no-install" "biome" "format"
          "--stdin-file-path" filepath))

  ;; Biome formata JS/TS/TSX, JSON e CSS. Não associar a .astro:
  ;; Astro não é um formato de entrada suportado pelo Biome.
  (dolist (mode '(js-mode
                  js-ts-mode
                  typescript-mode
                  typescript-ts-mode
                  tsx-ts-mode
                  json-mode
                  json-ts-mode
                  css-mode
                  css-ts-mode))
    (setf (alist-get mode apheleia-mode-alist) 'biome)))

;;; Atalhos do Biome no mapa de comandos do LSP.

(after! lsp-biome
  (map! :map lsp-command-map
        "o" #'lsp-biome-organize-imports
        "f" #'lsp-biome-fix-all))

;;; Busca

(after! consult
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --line-number . -g !node_modules -g !dist -g !.astro -g !coverage"))
