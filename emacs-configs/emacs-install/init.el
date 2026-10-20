;;; init.el --- Emacs-Kick (revisado) -*- lexical-binding: t; -*-
;; Author: Rahul Martim Juliato (revisão: correções e melhorias)
;; Version: 0.10.0
;; Package-Requires: ((emacs "30.1"))
;; License: GPL-2.0-or-later

;;; Commentary:
;; Config para quem vem do (neo)vim.  Leader = SPC.
;; Use junto com `early-init.el' (GC, package.el, UI sem flicker, LSP_USE_PLISTS).
;;
;; Ajuda: <leader> h f / h v / h k / h m.

;;; Code:

(require 'cl-lib)

;;;; ------------------------------------------------------------------
;;;; Performance
;;;; ------------------------------------------------------------------

;; GC alto durante o boot; depois volta para um valor sensato (64 MB).
;; (Deixar 1 GB para sempre causa pausas enormes quando o GC finalmente roda.)
(setq gc-cons-threshold #x40000000)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

(setq read-process-output-max (* 4 1024 1024))   ;; LSP: respostas grandes

;; JIT native-comp ligado: sem ele os pacotes rodam apenas em bytecode, a menos
;; que você pré-compile tudo.  Avisos ficam silenciosos.
(setq native-comp-jit-compilation t
      native-comp-async-report-warnings-errors 'silent)

;;;; ------------------------------------------------------------------
;;;; Compatibilidade com Emacs 31
;;;; ------------------------------------------------------------------

;; `treesit-ready-p' foi removida no Emacs 31, mas vários pacotes (treesit-auto,
;; astro-ts-mode, modos de terceiros...) ainda a chamam.  Shim equivalente:
(unless (fboundp 'treesit-ready-p)
  (defun treesit-ready-p (language &optional quiet)
    "Non-nil se tree-sitter e a grammar de LANGUAGE estão disponíveis."
    (and (treesit-available-p)
         (or (treesit-language-available-p language)
             (progn
               (unless quiet
                 (display-warning
                  'treesit (format "Grammar tree-sitter de `%s' não encontrada" language)))
               nil)))))

;;;; ------------------------------------------------------------------
;;;; straight.el + use-package
;;;; ------------------------------------------------------------------

(setq package-enable-at-startup nil)   ;; (o ideal é estar no early-init.el)

(setq straight-check-for-modifications '(check-on-save find-when-checking))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package '(project :type built-in))
(straight-use-package 'use-package)

;; Todo `use-package' usa straight por padrão.  Para pacotes built-in use
;; `:straight nil' (NÃO `:ensure nil': o straight o ignora e tenta baixar o
;; pacote, o que gerava "Could not find package window").
(setq straight-use-package-by-default t)

(defcustom ek-use-nerd-fonts t
  "Usa símbolos Nerd Fonts na configuração."
  :type 'boolean
  :group 'appearance)

;;;; ------------------------------------------------------------------
;;;; Instalação inicial (definida cedo de propósito: assim `M-x ek/first-install'
;;;; existe mesmo que algum pacote abaixo falhe no primeiro boot)
;;;; ------------------------------------------------------------------

(defmacro ek/step (label &rest body)
  "Executa BODY mostrando LABEL; um erro é reportado mas não interrompe o resto."
  (declare (indent 1))
  `(progn
     (message ">>> %s..." ,label)
     (condition-case err (progn ,@body)
       (error (message ">>> ERRO em %s: %S" ,label err)))))

(defun ek/first-install ()
  "Instala grammars tree-sitter e fontes nerd na primeira execução.
Requer `git' e um compilador C (gcc/clang) no PATH."
  (interactive)
  (switch-to-buffer "*Messages*")
  (message ">>> Configurando Emacs-Kick...")
  ;; Garante que os pacotes existem (se o init abortou antes de instalá-los
  ;; no primeiro boot, o `require' falharia com "no such file or directory").
  (ek/step "Instalando pacotes necessários"
    (dolist (p (append '(treesit-auto astro-ts-mode)
                       (when ek-use-nerd-fonts '(nerd-icons))))
      (straight-use-package p)))
  (make-directory (locate-user-emacs-file "tree-sitter") t)
  (dolist (prog '("git" "cc"))
    (unless (executable-find prog)
      (message ">>> AVISO: `%s' não encontrado no PATH (necessário para compilar grammars)" prog)))
  (ek/step "Tree-sitter parsers"
    (require 'treesit-auto)
    (treesit-auto-install-all))
  ;; O astro-ts-mode só carrega depois que tsx/css existem (instalados acima).
  (ek/step "Astro grammars"
    (require 'astro-ts-mode)
    (when (fboundp 'astro-ts-mode-install-grammars)
      (astro-ts-mode-install-grammars)))
  ;; Diagnóstico: lista o que continua faltando.
  (let ((missing (seq-remove #'treesit-language-available-p
                             '(typescript tsx javascript json css html yaml toml bash astro))))
    (if missing
        (message ">>> AVISO: grammars ainda ausentes: %s (veja os erros acima; precisa de git e cc)"
                 (mapconcat #'symbol-name missing ", "))
      (message ">>> Todas as grammars necessárias estão instaladas.")))
  (when ek-use-nerd-fonts
    (ek/step "Nerd Fonts"
      (require 'nerd-icons)
      (nerd-icons-install-fonts t)))   ;; t = sem pedir confirmação
  (message ">>> Pronto! Veja acima se houve ERRO.  Pressione qualquer tecla para fechar e reabra o Emacs.")
  (read-key)
  (kill-emacs))

;;;; ------------------------------------------------------------------
;;;; EMACS (built-in)
;;;; ------------------------------------------------------------------

(use-package emacs
  :straight nil
  :custom
  (auto-save-default nil)
  (column-number-mode t)
  (create-lockfiles nil)
  (delete-by-moving-to-trash t)
  (delete-selection-mode 1)
  (display-line-numbers-type 'relative)
  (global-auto-revert-non-file-buffers t)
  (history-length 100)
  (indent-tabs-mode nil)
  (inhibit-startup-message t)
  (initial-scratch-message "")
  (ispell-dictionary "en_US")
  (recentf-max-saved-items 200)
  (auto-revert-verbose nil)
  ;; Persiste também kill-ring e históricos de busca entre sessões.
  (savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
  (enable-recursive-minibuffers t)
  ;; M-x só lista comandos relevantes ao modo atual (combina com Vertico).
  (read-extended-command-predicate #'command-completion-default-include-p)
  (scroll-conservatively 101)
  (scroll-margin 3)
  (make-backup-files nil)
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  (ring-bell-function 'ignore)
  (split-width-threshold 300)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (tab-width 4)
  (treesit-font-lock-level 4)
  (truncate-lines t)
  (use-dialog-box nil)
  (use-short-answers t)
  ;; :emergency escondia TODOS os avisos (inclusive erros de config úteis).
  (warning-minimum-level :error)

  :hook
  ((prog-mode . display-line-numbers-mode)
   (prog-mode . electric-pair-local-mode))

  :config
  ;; ]b / [b pulam apenas buffers "de arquivo", ignorando *especiais*.
  (defun ek/skip-special-buffers (_window buffer _bury-or-kill)
    "Function for `switch-to-prev-buffer-skip'."
    (string-match-p "\\`\\*[^*]+\\*\\'" (buffer-name buffer)))
  (setq switch-to-prev-buffer-skip #'ek/skip-special-buffers)

  ;; Fonte (só em GUI e só se existir, evita erro/fallback feio).
  ;; Preferência: Nerd Font completa; senão JetBrains Mono (os ícones vêm da
  ;; fonte "Symbols Nerd Font Mono", instalada por `nerd-icons' ou pelo MacPorts).
  (when (display-graphic-p)
    (let ((family (seq-find (lambda (f) (find-font (font-spec :name f)))
                            '("JetBrainsMono Nerd Font" "JetBrains Mono"))))
      (when family
        (set-face-attribute 'default nil
                            :family family
                            :height (if (eq system-type 'darwin) 130 100)))))
  (when (eq system-type 'darwin)
    (setq mac-command-modifier 'meta))

  ;; Customizações feitas via interface (M-x customize) vão para outro arquivo.
  ;; Ele é carregado no FINAL do init.el (veja o fim do arquivo), para que os
  ;; valores salvos não sejam sobrescritos pelos `:custom' dos pacotes.
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))

  ;; Divisor vertical bonito.
  (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

  :init
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (when scroll-bar-mode (scroll-bar-mode -1))

  (global-auto-revert-mode 1)
  (recentf-mode 1)
  (savehist-mode 1)
  (save-place-mode 1)
  (winner-mode 1)
  (xterm-mouse-mode 1)
  (minibuffer-depth-indicate-mode 1)
  (global-so-long-mode 1)           ;; evita travar em arquivos com linhas gigantes (JS minificado)

  ;; Desempenho em linhas longas.
  (setq-default bidi-paragraph-direction 'left-to-right)
  (setq bidi-inhibit-bpa t)

  (set-default-coding-systems 'utf-8)

  ;; `emacs-startup-hook' (e não `after-init-hook'): só aqui `emacs-init-time'
  ;; já é confiável.
  (add-hook 'emacs-startup-hook
            (lambda ()
              (with-current-buffer (get-buffer-create "*scratch*")
                (goto-char (point-max))
                (insert (format ";;    Welcome to Emacs!\n;;\n;;    Loading time : %s\n;;    Packages     : %d\n"
                                (emacs-init-time)
                                (hash-table-count straight--recipe-cache)))))))

;;;; ------------------------------------------------------------------
;;;; WINDOW
;;;; ------------------------------------------------------------------

(use-package window
  :straight nil
  :custom
  (display-buffer-alist
   '(("\\*\\(Backtrace\\|Warnings\\|Compile-Log\\|[Hh]elp\\|Messages\\|Bookmark List\\|Ibuffer\\|Occur\\|eldoc.*\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))
     ("\\*\\(lsp-help\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))
     ("\\*\\(Flymake diagnostics\\|xref\\|Completions\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 1)))))

;;;; ------------------------------------------------------------------
;;;; DIRED
;;;; ------------------------------------------------------------------

(use-package dired
  :straight nil
  :custom
  (dired-listing-switches
   (if (and (eq system-type 'darwin) (not (executable-find "gls")))
       "-lah"
     "-lah --group-directories-first"))
  (dired-dwim-target t)
  ;; `open' no Linux pode ser o `openvt'; escolhe o opener certo por SO.
  (dired-guess-shell-alist-user
   (let ((opener (if (eq system-type 'darwin) "open" "xdg-open")))
     `(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" ,opener)
       ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" ,opener)
       (".*" ,opener))))
  (dired-kill-when-opening-new-dired-buffer t)
  :config
  (when (eq system-type 'darwin)
    (let ((gls (executable-find "gls")))
      (when gls (setq insert-directory-program gls)))))

;;;; ------------------------------------------------------------------
;;;; ERC
;;;; ------------------------------------------------------------------

(use-package erc
  :straight nil
  :defer t
  :custom
  (erc-join-buffer 'window)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-timestamp-format "[%H:%M]")
  (erc-autojoin-channels-alist '((".*\\.libera\\.chat" "#emacs"))))

;;;; ------------------------------------------------------------------
;;;; ISEARCH / VC / SMERGE (built-ins; os atalhos padrão já existem)
;;;; ------------------------------------------------------------------

(use-package isearch
  :straight nil
  :custom
  (isearch-lazy-count t)
  (lazy-count-prefix-format "(%s/%s) ")
  (lazy-count-suffix-format nil)
  (search-whitespace-regexp ".*?"))

(use-package vc
  :straight nil
  :defer t
  :config
  ;; Cores do <leader> g b (blame).
  (setq vc-annotate-color-map
        '((20 . "#f5e0dc") (40 . "#f2cdcd") (60 . "#f5c2e7") (80 . "#cba6f7")
          (100 . "#f38ba8") (120 . "#eba0ac") (140 . "#fab387") (160 . "#f9e2af")
          (180 . "#a6e3a1") (200 . "#94e2d5") (220 . "#89dceb") (240 . "#74c7ec")
          (260 . "#89b4fa") (280 . "#b4befe"))))

(use-package smerge-mode
  :straight nil
  :defer t)   ;; prefixo padrão: C-c ^ (u, l, n, p ...)

;;;; ------------------------------------------------------------------
;;;; ELDOC / FLYMAKE / ORG / WHICH-KEY
;;;; ------------------------------------------------------------------

(use-package eldoc
  :straight nil
  :custom
  (eldoc-idle-delay 0)
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-display-truncation-message nil)
  :init
  (global-eldoc-mode))

(use-package flymake
  :straight nil
  :defer t
  :hook (prog-mode . flymake-mode)
  :custom
  ;; Sem isto, `flymake-margin-indicators-string' não tem efeito.
  (flymake-indicator-type 'margins)
  (flymake-margin-indicators-string
   '((error "!»" compilation-error)
     (warning "»" compilation-warning)
     (note "»" compilation-info))))

(use-package org
  :straight nil
  :defer t)

(use-package which-key   ;; built-in desde o Emacs 30
  :straight nil
  :custom (which-key-idle-delay 0.4)
  :hook (after-init . which-key-mode))

;;;; ==================================================================
;;;; PACOTES EXTERNOS
;;;; ==================================================================

;;; Completion: vertico / orderless / marginalia / consult / embark
(use-package vertico
  :hook (after-init . vertico-mode)
  :custom
  (vertico-count 10)
  (vertico-resize nil)
  (vertico-cycle nil)
  :config
  ;; Prefixa o candidato atual com "» ".
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index start)
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face '(:foreground "#80adf0" :weight bold))
                   "  ")
                 (funcall orig cand prefix suffix index start)))))

;; Extensão que acompanha o Vertico: DEL apaga um diretório inteiro no find-file.
(use-package vertico-directory
  :straight nil
  :after vertico
  :bind (:map vertico-map
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :hook (after-init . marginalia-mode))

(use-package consult
  :defer t
  :bind (("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-s r" . consult-ripgrep))
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package embark
  :defer t
  :init
  ;; C-h após um prefixo lista os atalhos via completion (com Embark).
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; Tree-sitter
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))

;;; Markdown
(use-package markdown-mode
  :defer t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;;; Corfu
(use-package corfu
  :custom
  (corfu-auto nil)               ;; completa só com TAB
  (corfu-auto-prefix 1)
  (corfu-quit-no-match t)
  (corfu-scroll-margin 5)
  (corfu-max-width 50)
  (corfu-min-width 50)
  (corfu-popupinfo-delay 0.5)
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode t))

;; Popup do Corfu em terminal (Emacs 31+ já tem child frames em TTY).
(use-package corfu-terminal
  :unless (or (display-graphic-p) (>= emacs-major-version 31))
  :after corfu
  :config
  (corfu-terminal-mode 1))

(use-package nerd-icons-corfu
  :if ek-use-nerd-fonts
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;;; LSP
(use-package lsp-mode
  :defer t
  :commands lsp
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         ((js-mode js-ts-mode typescript-ts-base-mode
           css-mode css-ts-mode html-ts-mode json-ts-mode
           yaml-ts-mode toml-ts-mode astro-ts-mode
           go-ts-mode python-base-mode ruby-base-mode rust-ts-mode
           prisma-mode) . lsp-deferred))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-inlay-hint-enable nil)
  (lsp-completion-provider :none)               ;; Corfu faz a UI
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-diagnostics-provider :flymake)           ;; explícito (padrão :auto pode escolher flycheck)
  (lsp-enable-xref t)
  (lsp-auto-configure t)
  (lsp-enable-links nil)
  (lsp-eldoc-enable-hover t)
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (lsp-enable-imenu t)
  (lsp-enable-indentation nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-suggest-server-download t)
  (lsp-enable-symbol-highlighting t)
  (lsp-enable-text-document-color t)
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-modeline-workspace-status-enable t)
  (lsp-signature-doc-lines 1)
  (lsp-eldoc-render-all t)
  (lsp-completion-enable t)
  (lsp-completion-enable-additional-text-edit t)
  (lsp-enable-snippet nil)
  (lsp-completion-show-kind t)
  (lsp-lens-enable t)
  (lsp-headerline-breadcrumb-enable-symbol-numbers t)
  (lsp-headerline-arrow "▶")
  (lsp-headerline-breadcrumb-enable-diagnostics nil)
  (lsp-headerline-breadcrumb-icons-enable nil)
  (lsp-semantic-tokens-enable nil)
  :config
  ;; Os atalhos de LSP ficam AQUI: `lsp-mode-map' só existe depois que o
  ;; lsp-mode carrega (no original, o `evil' referenciava a variável cedo
  ;; demais e dava void-variable).
  (with-eval-after-load 'evil
    (evil-define-key 'normal lsp-mode-map
      (kbd "gr") #'lsp-find-references
      (kbd "gI") #'lsp-find-implementation
      (kbd "<leader> c a") #'lsp-execute-code-action
      (kbd "<leader> r n") #'lsp-rename
      (kbd "<leader> l f") #'lsp-format-buffer)
    (evil-normalize-keymaps)))

;; `:after lsp-mode' (sem `:defer t'): antes o pacote nunca era carregado e o
;; servidor do Tailwind não era registrado.
(use-package lsp-tailwindcss
  :after lsp-mode
  :init
  (setq lsp-tailwindcss-add-on-mode t)
  :config
  (add-to-list 'lsp-language-id-configuration '(".*\\.erb$" . "html")))

;;; Servidores extras: Astro e Taplo (TOML).  O Biome vem do pacote `lsp-biome' (abaixo).
;; Instalação (fora do Emacs):
;;   npm i -D --save-exact @biomejs/biome          ;; por projeto (usado pelo lsp-biome)
;;   npm i -g @astrojs/language-server typescript
;;   cargo install taplo-cli --locked              ;; ou: npm i -g @taplo/cli
;; ts-ls, json-ls e yaml-ls o lsp-mode baixa sozinho (lsp-enable-suggest-server-download).
(defun ek/locate-up (&rest names)
  "Primeiro diretório ancestral que contém algum de NAMES (ou nil)."
  (cl-some (lambda (n) (locate-dominating-file default-directory n)) names))

(defun ek/ts-tsdk ()
  "Caminho do `typescript/lib' local (ou global) exigido pelo astro-ls."
  (let ((root (ek/locate-up "node_modules/typescript/lib")))
    (cond (root (expand-file-name "node_modules/typescript/lib" root))
          ((executable-find "npm")
           (let ((g (string-trim (shell-command-to-string "npm root -g"))))
             (expand-file-name "typescript/lib" g))))))

(with-eval-after-load 'lsp-mode
  (dolist (entry '((astro-ts-mode . "astro")
                   (toml-ts-mode  . "toml")
                   (yaml-ts-mode  . "yaml")))
    (add-to-list 'lsp-language-id-configuration entry))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("astro-ls" "--stdio")
                                          (lambda () (executable-find "astro-ls")))
    :activation-fn (lsp-activate-on "astro")
    :initialization-options (lambda () (list :typescript (list :tsdk (ek/ts-tsdk))))
    :priority 1
    :server-id 'astro-ek))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("taplo" "lsp" "stdio")
                                          (lambda () (executable-find "taplo")))
    :activation-fn (lsp-activate-on "toml")
    :priority 1
    :server-id 'taplo-ek)))

;;; lsp-biome (cxa/lsp-biome): cliente do Biome para o lsp-mode (lint, formatação via
;;; LSP, organize imports, fix all).  Comportamento (conforme o código-fonte):
;;;  - só ativa se o projeto tem biome.json/biome.jsonc E o `biome' é encontrado
;;;    (node_modules/@biomejs/biome local, senão o do PATH);
;;;  - roda como add-on (`lsp-biome-add-on-mode' t), ao lado do typescript-language-server;
;;;  - tipos de arquivo em `lsp-biome-active-file-types' (js/ts/jsx/tsx/json/jsonc/css).
;;; Para formatar, prefira `<leader> m f' (apheleia -> biome): `<leader> l f' (LSP)
;;; pode escolher o formatador do ts-ls.
(use-package lsp-biome
  :straight (lsp-biome :type git :host github :repo "cxa/lsp-biome")
  :after lsp-mode
  :config
  (with-eval-after-load 'evil
    (evil-define-key 'normal lsp-mode-map
      (kbd "<leader> c o") #'lsp-biome-organize-imports
      (kbd "<leader> c x") #'lsp-biome-fix-all)
    (evil-normalize-keymaps)))

(use-package eldoc-box
  :defer t)

;;; Git: diff-hl / magit
(use-package diff-hl
  :hook ((after-init . global-diff-hl-mode)
         (after-init . diff-hl-flydiff-mode)
         (after-init . diff-hl-margin-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-side 'left)
  (diff-hl-margin-symbols-alist '((insert . "┃")
                                  (delete . "-")
                                  (change . "┃")
                                  (unknown . "┆")
                                  (ignored . "i"))))

(use-package magit
  :defer t
  :config
  (when ek-use-nerd-fonts
    (setopt magit-format-file-function #'magit-format-file-nerd-icons)))

;;; PATH no macOS: o Emacs gráfico não herda o PATH do shell (Homebrew /opt/homebrew,
;;; MacPorts /opt/local), então LSP e formatadores não achariam os binários.
(use-package exec-path-from-shell
  :if (and (eq system-type 'darwin) (or (display-graphic-p) (daemonp)))
  :custom
  (exec-path-from-shell-variables '("PATH" "MANPATH"))
  ;; `-i' (interativo) faz o zsh ler o ~/.zshrc, onde o nvm costuma ser carregado.
  (exec-path-from-shell-arguments '("-l" "-i"))
  :config
  (exec-path-from-shell-initialize))

;;; Clipboard no terminal
(use-package xclip
  :unless (display-graphic-p)
  :hook (after-init . xclip-mode))

;;; Indent guides (indent-guide é lento/antigo; highlight-indent-guides é mais estável)
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-character ?│)
  (highlight-indent-guides-responsive 'top))

;;; node_modules/.bin local.
;; O original usava `:custom (eval-after-load ...)', que só setava uma variável
;; sem efeito: o hook nunca era instalado.  Correto é `:hook'.
(use-package add-node-modules-path
  :hook ((typescript-ts-base-mode js-base-mode json-ts-mode css-base-mode
          yaml-ts-mode astro-ts-mode) . add-node-modules-path))

;;; Astro (precisa das grammars astro/css/tsx: veja `ek/first-install')
;; `:defer t': o astro-ts-mode exige as grammars tsx/css já instaladas ao ser
;; carregado; carregá-lo no boot gerava erro antes de `ek/first-install' rodar.
(use-package astro-ts-mode
  :defer t)

(defun ek/astro-mode ()
  "Ativa `astro-ts-mode', oferecendo instalar as grammars se faltarem.
Evita o aviso \"language grammar for astro failed to load\"."
  (interactive)
  (require 'astro-ts-mode)
  (when (and (not (treesit-language-available-p 'astro))
             (y-or-n-p "Grammar tree-sitter do Astro não instalada.  Instalar agora (astro, css, tsx)? "))
    (astro-ts-mode-install-grammars))
  (astro-ts-mode))

;; Entra na frente da entrada que o próprio pacote registra.
(add-to-list 'auto-mode-alist '("\\.astro\\'" . ek/astro-mode))

(add-to-list 'auto-mode-alist '("\\.jsonc\\'" . json-ts-mode))

;;; .editorconfig (built-in no Emacs 30): indentação consistente com o time
(use-package editorconfig
  :straight nil
  :init (editorconfig-mode 1))

;;; Shell: shellcheck (diagnóstico no flymake) + shfmt (formatação, via apheleia)
;; O backend `sh-shellcheck-flymake' já vem com o Emacs; basta ter o binário
;; `shellcheck' no PATH.  Dica: coloque `external-sources=true' no .shellcheckrc.
(use-package sh-script
  :straight nil
  :hook (sh-base-mode . (lambda ()
                          (add-hook 'flymake-diagnostic-functions
                                    #'sh-shellcheck-flymake nil t))))

;;; Formatação ao salvar (assíncrona, sem pular o cursor)
;;  JS/TS/JSON/CSS : Biome se o projeto tiver biome.json; senão Prettier se tiver
;;                   config de prettier; senão NÃO formata (evita reformatar à força).
;;  Astro / YAML   : Prettier, somente se o projeto tiver config de prettier
;;                   (.astro precisa de prettier-plugin-astro).
;;  TOML           : taplo     |  sh/bash : shfmt
;;  Obs.: a chave "prettier" dentro do package.json não é detectada; nesse caso use
;;  `<leader> m f' (formata manualmente) ou crie um .prettierrc.
(defconst ek/prettier-config-files
  '(".prettierrc" ".prettierrc.json" ".prettierrc.yaml" ".prettierrc.yml"
    ".prettierrc.js" ".prettierrc.cjs" ".prettierrc.mjs" ".prettierrc.toml"
    "prettier.config.js" "prettier.config.cjs" "prettier.config.mjs"
    "prettier.config.ts")
  "Arquivos que indicam que o projeto usa Prettier.")

(defun ek/pick-web-formatter ()
  "JS/TS/JSON/CSS: Biome se houver biome.json, senão Prettier se houver config."
  (cond
   ((ek/locate-up "biome.json" "biome.jsonc")
    (setq-local apheleia-formatter 'ek-biome))
   ((apply #'ek/locate-up ek/prettier-config-files)
    (setq-local apheleia-formatter 'prettier))
   (t (setq-local apheleia-inhibit t))))

(defun ek/pick-prettier-formatter ()
  "YAML/Astro: formata com Prettier somente se o projeto o configurar."
  (unless (apply #'ek/locate-up ek/prettier-config-files)
    (setq-local apheleia-inhibit t)))

(dolist (h '(js-base-mode-hook typescript-ts-base-mode-hook
             json-ts-mode-hook css-base-mode-hook))
  (add-hook h #'ek/pick-web-formatter))
(dolist (h '(yaml-ts-mode-hook astro-ts-mode-hook))
  (add-hook h #'ek/pick-prettier-formatter))

(use-package apheleia
  :hook (after-init . apheleia-global-mode)
  :config
  (setf (alist-get 'ek-biome apheleia-formatters)
        '("biome" "format" "--stdin-file-path" filepath))
  (setf (alist-get 'taplo apheleia-formatters)
        '("taplo" "format" "--stdin-filepath" filepath "-"))

  (dolist (m '(yaml-ts-mode astro-ts-mode))
    (setf (alist-get m apheleia-mode-alist) 'prettier))
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'taplo)
  (dolist (m '(sh-mode bash-ts-mode))
    (setf (alist-get m apheleia-mode-alist) 'shfmt)))

(defun ek/biome-fix ()
  "Roda `biome check --write' (format + lint fixes + imports) no arquivo atual."
  (interactive)
  (unless buffer-file-name (user-error "Buffer sem arquivo"))
  (save-buffer)
  (if (zerop (call-process "biome" nil "*biome*" nil "check" "--write"
                           (expand-file-name buffer-file-name)))
      (revert-buffer t t t)
    (display-buffer "*biome*")
    (user-error "biome check falhou")))

;;;; ------------------------------------------------------------------
;;;; UNDO-TREE (precisa vir antes do evil usar o sistema de undo)
;;;; ------------------------------------------------------------------

(use-package undo-tree
  :hook (after-init . global-undo-tree-mode)
  :init
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        undo-limit 800000
        undo-strong-limit 12000000
        undo-outer-limit 120000000)
  :config
  (let ((dir (locate-user-emacs-file "cache/undo")))
    (make-directory dir t)
    (setq undo-tree-history-directory-alist `(("." . ,dir)))))

;;;; ------------------------------------------------------------------
;;;; EVIL
;;;; ------------------------------------------------------------------

(defun ek/lsp-describe-and-jump ()
  "Mostra a doc em hover e pula para o buffer de ajuda."
  (interactive)
  (if (bound-and-true-p lsp-mode)
      (progn
        (lsp-describe-thing-at-point)
        (when (get-buffer "*lsp-help*")
          (switch-to-buffer-other-window "*lsp-help*")))
    (eldoc-doc-buffer t)))

(use-package evil
  :hook (after-init . evil-mode)
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-u-delete t
        evil-want-fine-undo t
        evil-want-C-i-jump nil          ;; no terminal TAB == C-i; não sequestra o TAB
        evil-want-Y-yank-to-eol t       ;; Y = y$ (como no neovim)
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-undo-system 'undo-tree)
  :config
  (evil-set-leader 'normal (kbd "SPC"))
  (evil-set-leader 'visual (kbd "SPC"))

  (defun ek/leader-keys (alist)
    "Define atalhos <leader> a partir de ALIST de (\"keys\" . comando)."
    (dolist (b alist)
      (evil-define-key 'normal 'global
        (kbd (concat "<leader> " (car b))) (cdr b))))

  (ek/leader-keys
   '(;; Busca
     ("s f" . consult-find)
     ("s g" . consult-grep)
     ("s G" . consult-git-grep)
     ("s r" . consult-ripgrep)
     ("s h" . consult-info)
     ("/"   . consult-line)
     ;; Diagnósticos / dired
     ("x x" . consult-flymake)
     ("x d" . dired)
     ("x j" . dired-jump)
     ("x f" . find-file)
     ;; Árvore de arquivos
     ("e e" . neotree-toggle)
     ("e d" . dired-jump)
     ;; Git
     ("g g" . magit-status)
     ("g l" . magit-log-current)
     ("g d" . magit-diff-buffer-file)
     ("g D" . diff-hl-show-hunk)
     ("g b" . vc-annotate)
     ;; Buffers
     ("SPC" . consult-buffer)
     ("b i" . consult-buffer)
     ("b l" . consult-buffer)
     ("b b" . ibuffer)
     ("b d" . kill-current-buffer)
     ("b k" . kill-current-buffer)
     ("b x" . kill-current-buffer)
     ("b s" . save-buffer)
     ;; Projetos
     ("p b" . consult-project-buffer)
     ("p p" . project-switch-project)
     ("p f" . project-find-file)
     ("p g" . project-find-regexp)
     ("p k" . project-kill-buffers)
     ("p D" . project-dired)
     ;; Diversos
     ("P"   . consult-yank-from-kill-ring)   ;; `P' puro continua sendo o paste do evil
     ("."   . embark-act)
     ("u"   . undo-tree-visualize)
     ("m f" . apheleia-format-buffer)
     ("m c" . ek/biome-fix)
     ("t m" . toggle-frame-maximized)    ;; alterna maximizado (GUI)
     ("t f" . toggle-frame-fullscreen)   ;; alterna tela cheia (GUI)
     ;; Ajuda
     ("h m" . describe-mode)
     ("h f" . describe-function)
     ("h v" . describe-variable)
     ("h k" . describe-key)))

  ;; Navegação
  (evil-define-key 'normal 'global (kbd "] d") #'flymake-goto-next-error)
  (evil-define-key 'normal 'global (kbd "[ d") #'flymake-goto-prev-error)
  (evil-define-key 'normal 'global (kbd "] c") #'diff-hl-next-hunk)
  (evil-define-key 'normal 'global (kbd "[ c") #'diff-hl-previous-hunk)
  (evil-define-key 'normal 'global (kbd "] b") #'switch-to-next-buffer)
  (evil-define-key 'normal 'global (kbd "[ b") #'switch-to-prev-buffer)
  (evil-define-key 'normal 'global (kbd "] t") #'tab-next)
  (evil-define-key 'normal 'global (kbd "[ t") #'tab-previous)

  ;; Emacs 31 traz child frames para TTY; no 30 usa buffer de ajuda.
  (evil-define-key 'normal 'global (kbd "K")
    (if (>= emacs-major-version 31)
        #'eldoc-box-help-at-point
      #'ek/lsp-describe-and-jump))

  ;; Comentários
  (evil-define-key 'normal 'global (kbd "gcc") #'comment-line)
  (evil-define-key 'visual 'global (kbd "gc") #'comment-or-uncomment-region))

;; Cursor muda de forma por estado também no terminal (bloco/barra).
(use-package evil-terminal-cursor-changer
  :unless (display-graphic-p)
  :after evil
  :config
  (evil-terminal-cursor-changer-activate))

(use-package evil-collection
  :after evil
  :custom
  (evil-collection-want-find-usages-bindings t)
  :config
  (evil-collection-init))

;; cs'" troca aspas simples por duplas; cs"<p> -> <p>texto</p>
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; % pula entre pares/tags
(use-package evil-matchit
  :after evil
  :config
  (global-evil-matchit-mode 1))

;;;; ------------------------------------------------------------------
;;;; UI
;;;; ------------------------------------------------------------------

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package dotenv-mode
  :mode ("\\.env\\'" "\\.env\\..*\\'"))

(use-package pulsar
  :hook (after-init . pulsar-global-mode)
  :config
  (setq pulsar-pulse t
        pulsar-delay 0.025
        pulsar-iterations 10
        pulsar-face 'evil-ex-lazy-highlight)
  (dolist (fn '(evil-scroll-down evil-yank evil-yank-line evil-delete
                evil-delete-line evil-jump-item flymake-goto-next-error
                flymake-goto-prev-error diff-hl-next-hunk diff-hl-previous-hunk))
    (add-to-list 'pulsar-pulse-functions fn)))

(use-package nerd-icons
  :if ek-use-nerd-fonts)

(use-package nerd-icons-dired
  :if ek-use-nerd-fonts
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :if ek-use-nerd-fonts
  :after (nerd-icons marginalia)
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-buffer-file-name-style 'buffer-name)
  (doom-modeline-project-detection 'project)
  (doom-modeline-buffer-name t)
  (doom-modeline-vcs-max-length 25)
  (doom-modeline-icon ek-use-nerd-fonts))

(use-package neotree
  :defer t
  :custom
  (neo-show-hidden-files t)
  (neo-theme (if ek-use-nerd-fonts 'nerd-icons 'nerd))
  (neo-vc-integration '(face char)))

;; O flavor precisa ser definido ANTES do `load-theme'; os faces do diff-hl são
;; ajustados depois do tema (senão o tema pode sobrescrevê-los).
(use-package catppuccin-theme
  :custom
  (catppuccin-flavor 'mocha)
  :config
  (load-theme 'catppuccin :no-confirm)
  (custom-set-faces
   `(diff-hl-change ((t (:background unspecified :foreground ,(catppuccin-get-color 'blue)))))
   `(diff-hl-delete ((t (:background unspecified :foreground ,(catppuccin-get-color 'red)))))
   `(diff-hl-insert ((t (:background unspecified :foreground ,(catppuccin-get-color 'green)))))))

;;;; ------------------------------------------------------------------
;;;; Customizações salvas pela interface (carregadas por último)
;;;; ------------------------------------------------------------------
(when (and (boundp 'custom-file) custom-file)
  (load custom-file 'noerror 'nomessage))

(provide 'init)
;;; init.el ends here
