;;; init.el --- Emacs vanilla moderno: tree-sitter + eglot + evil -*- lexical-binding: t; -*-

;; Requer Emacs 30+ (testado pensando no 31).
;; Coloque early-init.el ao lado deste arquivo, em ~/.emacs.d/.
;;
;; Binários externos (servidores LSP, formatadores, rg/fd):
;;   bash install-deps.sh   (MacPorts + nvm/npm; `bash install-deps.sh --check` verifica)
;;   O coreutils do MacPorts fornece o `gls`, usado pelo dired no macOS.

;;;; ------------------------------------------------------------
;;;; Pacotes
;;;; ------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setopt use-package-always-ensure t)

;; Mantém o init.el limpo: o Customize escreve em outro arquivo
(setopt custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :config (exec-path-from-shell-initialize))

;;;; ------------------------------------------------------------
;;;; Padrões modernos do Emacs
;;;; ------------------------------------------------------------
(setopt use-short-answers t               ; y/n em vez de yes/no
        ring-bell-function #'ignore
        inhibit-startup-screen t
        initial-scratch-message nil
        make-backup-files nil
        auto-save-default nil
        create-lockfiles nil
        enable-recursive-minibuffers t
        tab-always-indent 'complete
        read-extended-command-predicate #'command-completion-default-include-p
        help-window-select t
        scroll-conservatively 101
        scroll-margin 3
        sentence-end-double-space nil)
(setq-default indent-tabs-mode nil
              tab-width 2)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setopt display-line-numbers-type 'relative)

(pixel-scroll-precision-mode 1)
(global-auto-revert-mode 1)               ; recarrega arquivos alterados fora
(savehist-mode 1)                         ; lembra histórico do minibuffer
(save-place-mode 1)
(recentf-mode 1)
(setopt recentf-max-saved-items 200)
(electric-pair-mode 1)
(show-paren-mode 1)
(global-so-long-mode 1)                   ; protege contra linhas gigantes
(repeat-mode 1)
(editorconfig-mode 1)                     ; respeita .editorconfig (embutido)

;; Tema (modus é embutido) e fonte
(load-theme 'modus-vivendi-tinted t)
(when (find-font (font-spec :name "Lekton Nerd Font Mono"))
  (set-face-attribute 'default nil :family "Lekton Nerd Font Mono" :height 160))

;; Dired decente no macOS (usa gls do coreutils)
(use-package dired
  :ensure nil
  :custom
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-dwim-target t)
  :config
  (when-let* ((gls (executable-find "gls")))
    (setopt insert-directory-program gls
            dired-use-ls-dired t
            dired-listing-switches "-alh --group-directories-first")))

;;;; ------------------------------------------------------------
;;;; Completion: vertico + orderless + marginalia + consult + embark + corfu
;;;; ------------------------------------------------------------
(use-package vertico
  :init (vertico-mode)
  :custom (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))
                                   (eglot (styles orderless))
                                   (eglot-capf (styles orderless))))
  (completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)))

(use-package embark-consult
  :demand t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :init (global-corfu-mode))

(use-package corfu-popupinfo
  :ensure nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode))

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

;;;; ------------------------------------------------------------
;;;; Git
;;;; ------------------------------------------------------------
(use-package magit
  :defer t
  :custom (magit-diff-refine-hunk t))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (diff-hl-flydiff-mode 1))

;;;; ------------------------------------------------------------
;;;; Tree-sitter
;;;; ------------------------------------------------------------
(setq treesit-font-lock-level 4)

;; Emacs 31: oferece instalar a gramática automaticamente ao abrir o arquivo
;; (se a variável não existir na sua versão, é ignorada).
(setq treesit-auto-install-grammar 'ask)

(setq treesit-language-source-alist
      '((bash       "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3")
        (http       "https://github.com/rest-nvim/tree-sitter-http")
        (astro      "https://github.com/virchau13/tree-sitter-astro")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.1" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src")
        (json       "https://github.com/tree-sitter/tree-sitter-json" "v0.24.8")
        (lua        "https://github.com/tree-sitter-grammars/tree-sitter-lua" "v0.3.0")
        (yaml       "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "v0.7.0")
        (toml       "https://github.com/tree-sitter-grammars/tree-sitter-toml" "v0.7.0")
        (css        "https://github.com/tree-sitter/tree-sitter-css" "v0.23.1")
        (html       "https://github.com/tree-sitter/tree-sitter-html" "v0.23.2")))

(defun my/treesit-install-all ()
  "Instala as gramáticas tree-sitter que ainda não estão disponíveis."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (message "Instalando gramática tree-sitter: %s" lang)
      (treesit-install-language-grammar lang))))

(setq major-mode-remap-alist
      '((sh-mode         . bash-ts-mode)
        (bash-mode       . bash-ts-mode)
        (js-mode         . js-ts-mode)
        (javascript-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (js-json-mode    . json-ts-mode)
        (json-mode       . json-ts-mode)
        (yaml-mode       . yaml-ts-mode)
        (conf-toml-mode  . toml-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.\\(?:[cm]?js\\|jsx\\)\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.\\(?:[cm]?ts\\)\\'"       . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"                   . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.\\(?:json\\|jsonc\\)\\'"  . json-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'"                 . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.toml\\'"                  . toml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.lua\\'"                   . lua-ts-mode))
(add-to-list 'auto-mode-alist '("\\.\\(?:sh\\|bash\\)\\'"     . bash-ts-mode))

(use-package astro-ts-mode
  :mode "\\.astro\\'"
  :custom (astro-ts-mode-indent-offset 2))

;;;; ------------------------------------------------------------
;;;; LSP: eglot + flymake
;;;; ------------------------------------------------------------
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-show-diagnostics-at-end-of-line 'short)) ; Emacs 30+

(use-package eldoc
  :ensure nil
  :custom (eldoc-idle-delay 0.3))

(use-package eglot
  :ensure nil
  :hook ((astro-ts-mode bash-ts-mode json-ts-mode lua-ts-mode
          js-ts-mode typescript-ts-mode tsx-ts-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-config '(:size 0))
  (eglot-sync-connect nil)
  (eglot-extend-to-xref t))

(defun my/tsdk ()
  "Diretório lib do typescript do projeto (ou global)."
  (let* ((root (locate-dominating-file default-directory "node_modules/typescript"))
         (local (and root (expand-file-name "node_modules/typescript/lib" root))))
    (or local
        (when-let* ((tsc (executable-find "tsc")))
          (expand-file-name "../lib/node_modules/typescript/lib"
                            (file-name-directory (file-truename tsc)))))))

;; Tailwind junto com ts_ls/astro-ls exige multiplexar servidores.
;; Instale `rass` (pip install rassumfrassum) e ponha t abaixo.
(defvar my/use-rass nil
  "Se não-nil e `rass' estiver no PATH, combina o servidor principal + tailwindcss.")

(defun my/with-tailwind (cmd)
  (if (and my/use-rass (executable-find "rass"))
      `("rass" "--" ,@cmd "--" "tailwindcss-language-server" "--stdio")
    cmd))

(with-eval-after-load 'eglot
  (setf (alist-get 'bash-ts-mode eglot-server-programs)
        '("bash-language-server" "start"))
  (setf (alist-get 'json-ts-mode eglot-server-programs)
        '("vscode-json-language-server" "--stdio"))
  (setf (alist-get 'lua-ts-mode eglot-server-programs)
        '("lua-language-server"))
  (setf (alist-get '(js-ts-mode typescript-ts-mode tsx-ts-mode) eglot-server-programs
                   nil nil #'equal)
        (lambda (&rest _) (my/with-tailwind '("typescript-language-server" "--stdio"))))
  (setf (alist-get 'astro-ts-mode eglot-server-programs)
        (lambda (&rest _)
          (my/with-tailwind
           `("astro-ls" "--stdio"
             :initializationOptions (:typescript (:tsdk ,(or (my/tsdk) ""))))))))

;;;; ------------------------------------------------------------
;;;; Formatadores (apheleia)
;;;; ------------------------------------------------------------
(use-package apheleia
  :init (apheleia-global-mode +1)
  :config
  (setf (alist-get 'prettier-astro apheleia-formatters)
        '("apheleia-npx" "prettier" "--stdin-filepath" filepath
          "--plugin" "prettier-plugin-astro" "--parser" "astro"))
  (setf (alist-get 'shfmt   apheleia-formatters) '("shfmt" "-filename" filepath "-i" "2"))
  (setf (alist-get 'stylua  apheleia-formatters) '("stylua" "--search-parent-directories"
                                                   "--stdin-filepath" filepath "-"))
  (setf (alist-get 'taplo   apheleia-formatters) '("taplo" "format" "-"))
  (setf (alist-get 'yamlfmt apheleia-formatters) '("yamlfmt" "-in"))
  (dolist (entry '((astro-ts-mode      . prettier-astro)
                   (bash-ts-mode       . shfmt)
                   (js-ts-mode         . prettier)
                   (typescript-ts-mode . prettier)
                   (tsx-ts-mode        . prettier)
                   (json-ts-mode       . prettier)
                   (lua-ts-mode        . stylua)
                   (toml-ts-mode       . taplo)
                   (yaml-ts-mode       . yamlfmt)))
    (setf (alist-get (car entry) apheleia-mode-alist) (cdr entry))))

;; .prettierrc para Astro:
;;   { "plugins": ["prettier-plugin-astro"],
;;     "overrides": [{ "files": "*.astro", "options": { "parser": "astro" } }] }

;;;; ------------------------------------------------------------
;;;; which-key (embutido)
;;;; ------------------------------------------------------------
(use-package which-key
  :ensure nil
  :custom
  (which-key-idle-delay 0.4)
  (which-key-idle-secondary-delay 0.05)
  (which-key-sort-order #'which-key-key-order-alpha)
  :init (which-key-mode 1))

;;;; ------------------------------------------------------------
;;;; Evil
;;;; ------------------------------------------------------------
;; Precisam ser definidas ANTES de carregar o evil (por isso setq).
(setq evil-want-integration t
      evil-want-keybinding nil
      evil-want-C-u-scroll t
      evil-want-C-i-jump nil
      evil-undo-system 'undo-redo
      evil-respect-visual-line-mode t
      evil-split-window-below t
      evil-vsplit-window-right t)

(use-package evil
  :init (evil-mode 1)
  :config
  (define-key evil-insert-state-map (kbd "C-g") #'evil-normal-state)
  (evil-global-set-key 'motion "j" #'evil-next-visual-line)
  (evil-global-set-key 'motion "k" #'evil-previous-visual-line)
  (evil-set-leader '(normal visual motion) (kbd "SPC"))
  (evil-set-leader '(normal visual motion) (kbd ",") t))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode 1))

(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))

;;;; ------------------------------------------------------------
;;;; Atalhos com leader (SPC)
;;;; ------------------------------------------------------------
(with-eval-after-load 'evil
  (evil-define-key '(normal visual motion) 'global
    ;; Atalhos rápidos
    (kbd "<leader>SPC") #'project-find-file
    (kbd "<leader>,")   #'consult-buffer
    (kbd "<leader>/")   #'consult-ripgrep
    (kbd "<leader>.")   #'embark-act
    ;; Arquivos
    (kbd "<leader>ff") #'find-file
    (kbd "<leader>fr") #'consult-recent-file
    (kbd "<leader>fs") #'save-buffer
    ;; Buffers
    (kbd "<leader>bb") #'consult-buffer
    (kbd "<leader>bd") #'kill-current-buffer
    (kbd "<leader>bn") #'next-buffer
    (kbd "<leader>bp") #'previous-buffer
    ;; Janelas
    (kbd "<leader>wv") #'evil-window-vsplit
    (kbd "<leader>ws") #'evil-window-split
    (kbd "<leader>wd") #'evil-window-delete
    (kbd "<leader>ww") #'other-window
    ;; Busca
    (kbd "<leader>ss") #'consult-line
    (kbd "<leader>si") #'consult-imenu
    (kbd "<leader>sp") #'consult-ripgrep
    (kbd "<leader>sf") #'consult-fd
    ;; Projeto
    (kbd "<leader>pp") #'project-switch-project
    (kbd "<leader>pf") #'project-find-file
    (kbd "<leader>pb") #'consult-project-buffer
    ;; Git
    (kbd "<leader>gg") #'magit-status
    (kbd "<leader>gb") #'magit-blame
    (kbd "<leader>gl") #'magit-log-current
    ;; Código / LSP
    (kbd "<leader>cr") #'eglot-rename
    (kbd "<leader>ca") #'eglot-code-actions
    (kbd "<leader>cf") #'apheleia-format-buffer
    (kbd "<leader>co") #'eglot-code-action-organize-imports
    (kbd "<leader>cd") #'consult-flymake
    (kbd "<leader>ce") #'eglot
    ;; Toggle
    (kbd "<leader>tt") #'modus-themes-toggle
    (kbd "<leader>tl") #'display-line-numbers-mode
    ;; Ajuda e sair
    (kbd "<leader>h")  help-map
    (kbd "<leader>qq") #'save-buffers-kill-terminal
    ;; Navegação estilo LSP
    (kbd "gd") #'xref-find-definitions
    (kbd "gr") #'xref-find-references
    (kbd "K")  #'eldoc-doc-buffer
    (kbd "]d") #'flymake-goto-next-error
    (kbd "[d") #'flymake-goto-prev-error)

  (which-key-add-key-based-replacements
    "SPC f" "arquivos"
    "SPC b" "buffers"
    "SPC w" "janelas"
    "SPC s" "busca"
    "SPC p" "projeto"
    "SPC g" "git"
    "SPC c" "código"
    "SPC t" "toggle"
    "SPC h" "ajuda"
    "SPC q" "sair"))

(provide 'init)
;;; init.el ends here
