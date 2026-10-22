;;; init.el --- Emacs config -*- lexical-binding: t; -*-

;; ==========================================
;; 0. WORKAROUNDS (Emacs 31 / MacPorts / macOS)
;; ==========================================
;; Os workarounds (crash de fontes no Cocoa e shim de treesit-ready-p) ficam em
;; ~/.emacs.d/early-init.el, porque precisam rodar antes dos autoloads.

;; ==========================================
;; 1. PERFORMANCE & BASIC UI
;; ==========================================
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

(setq make-backup-files nil)
(setq auto-save-default nil)

;; Responder y/n em vez de digitar "yes"/"no" por extenso (Emacs 28+).
(setq use-short-answers t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)

(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold 16777216)))

;; ==========================================
;; 1.5 macOS OPTION KEY AS META
;; ==========================================
(when (eq system-type 'darwin)
  (setq ns-option-modifier 'meta
        ns-right-option-modifier 'meta))

;; ==========================================
;; 1.6 FONTE (FAMILIA E TAMANHO)
;; ==========================================
;; Mude aqui e reinicie, ou use M-x my/set-font / my/set-font-size (SPC t f / SPC t s).
;; Menlo ja vem com o macOS. Outras: "JetBrains Mono", "Fira Code", "SF Mono".
(defvar my/font-family "Menlo" "Familia da fonte padrao.")
(defvar my/font-size 14 "Tamanho da fonte padrao, em pontos.")

(defun my/apply-font ()
  "Aplica `my/font-family' e `my/font-size' ao face default."
  (interactive)
  (when (display-graphic-p)
    (if (find-font (font-spec :family my/font-family))
        (set-face-attribute 'default nil
                            :family my/font-family
                            :height (* 10 my/font-size))
      (message "Fonte \"%s\" nao encontrada" my/font-family))))

(defun my/set-font (family)
  "Escolhe a FAMILY da fonte e aplica."
  (interactive
   (list (completing-read "Fonte: " (delete-dups (font-family-list))
                          nil nil nil nil my/font-family)))
  (setq my/font-family family)
  (my/apply-font))

(defun my/set-font-size (size)
  "Define o tamanho SIZE (em pontos) da fonte e aplica."
  (interactive (list (read-number "Tamanho (pt): " my/font-size)))
  (setq my/font-size size)
  (my/apply-font))

(add-hook 'after-init-hook #'my/apply-font)

;; ==========================================
;; 2. PACKAGES (MELPA)
;; ==========================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless package-archive-contents
  (ignore-errors (package-refresh-contents)))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Emacs.app aberto pelo Dock nao herda o PATH do shell; sem isso o astro-ls
;; nao acha node/npm e o Eglot fica reconectando.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :init
  ;; "-i" tambem le o ~/.zshrc, onde o nvm costuma ser carregado.
  (setq exec-path-from-shell-arguments '("-l" "-i")
        exec-path-from-shell-warn-duration-millis 3000)
  :config
  (exec-path-from-shell-initialize))

;; ==========================================
;; 3. THEME, ICONS, MODELINE
;; ==========================================
;; Icones (rodar uma vez: M-x nerd-icons-install-fonts)
(use-package nerd-icons
  :defer t)

(use-package nerd-icons-dired
  :after nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package doom-themes
  :init
  (setq doom-themes-enable-bold nil
        doom-themes-enable-italic nil)
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config))

(use-package doom-modeline
  :after doom-themes
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 4)
  (doom-modeline-lsp t)
  (doom-modeline-modal t)
  (doom-modeline-icon nil)) ; icones da modeline ja derrubaram o Emacs; teste t se quiser

;; ==========================================
;; 4. EVIL
;; ==========================================
(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :demand t
  :init
  ;; Don't let evil-collection steal SPC in dired/magit/etc. (our leader key)
  (setq evil-collection-key-blacklist '("SPC"))
  :config
  (evil-collection-init))

;; Comentar como no Vim: gcc (linha), gc{movimento} (ex.: gcap), gc no visual.
;; O evil puro nao traz operador de comentario.
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

;; ESC quits everything
(with-eval-after-load 'evil
  (defun my-evil-escape-everything ()
    "Quit minibuffer, visual state or prompts with ESC."
    (interactive)
    (cond
     ((minibuffer-window-active-p (minibuffer-window))
      (abort-recursive-edit))
     ((evil-visual-state-p)
      (evil-exit-visual-state))
     (t
      (keyboard-quit))))
  (define-key evil-normal-state-map (kbd "<escape>") #'my-evil-escape-everything)
  (define-key evil-motion-state-map (kbd "<escape>") #'my-evil-escape-everything))

;; ==========================================
;; 5. DIRED
;; ==========================================
;; macOS BSD ls lacks --group-directories-first. Install GNU ls:
;;   sudo port install coreutils
(when (and (eq system-type 'darwin) (executable-find "gls"))
  (setq insert-directory-program "gls"))

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches
   (if (executable-find "gls")
       "-agho --group-directories-first"
     "-agho"))
  (dired-dwim-target t)
  :hook
  (dired-mode . dired-hide-details-mode))

;; ==========================================
;; 6. COMPLETION & PROJECTS
;; ==========================================
(use-package recentf
  :ensure nil
  :init (recentf-mode 1)
  :custom (recentf-max-saved-items 200))

(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult)

(use-package projectile
  :init
  (projectile-mode +1)
  :custom
  (projectile-indexing-method 'hybrid)
  (projectile-project-search-path '("~/Codes"))
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; ==========================================
;; 7. MAGIT
;; ==========================================
(use-package magit
  :commands magit-status)

;; ==========================================
;; 8. CORFU (Emacs 31 suporta child frames no terminal)
;; ==========================================
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)  ; padrao 0.2
  (corfu-auto-prefix 2)   ; padrao 3: o popup so aparecia apos 3 caracteres
  (corfu-quit-no-match t)
  :init
  (global-corfu-mode))

;; ==========================================
;; 9. TREE-SITTER
;; ==========================================
;; Gramaticas: M-x treesit-auto-install-all
;; Se alguma falhar (ex.: astro): M-x treesit-install-language-grammar RET astro
(setq treesit-language-source-alist
      '((bash       "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3")
        (http       "https://github.com/rest-nvim/tree-sitter-http")
        (astro      "https://github.com/virchau13/tree-sitter-astro")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.1" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src")
        (json       "https://github.com/tree-sitter/tree-sitter-json" "v0.24.1")
        (lua        "https://github.com/tree-sitter-grammars/tree-sitter-lua" "v0.3.0")
        (yaml       "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "v0.7.0")
        (toml       "https://github.com/tree-sitter-grammars/tree-sitter-toml" "v0.7.0")
        (css        "https://github.com/tree-sitter/tree-sitter-css" "v0.23.1")
        (html       "https://github.com/tree-sitter/tree-sitter-html" "v0.23.2")))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode 1))

;; Real Astro mode from MELPA (font-lock, indentation, grammar helper)
(use-package astro-ts-mode
  :mode "\\.astro\\'")

;; ==========================================
;; 9.2 EGLOT + TYPESCRIPT/ASTRO/CSS PRESET
;; ==========================================
;; Prereqs (global or per project):
;;   npm i -g typescript typescript-language-server \
;;            @astrojs/language-server vscode-langservers-extracted
(use-package eglot
  :ensure nil
  :hook ((js-ts-mode typescript-ts-mode tsx-ts-mode css-ts-mode astro-ts-mode)
         . eglot-ensure)
  :config
  ;; Mantido: o astro-ls pede didChangeWatchedFiles com o glob "**/*.{js,ts,astro,...}".
  ;; No macOS o Eglot usa kqueue (um descritor por diretorio, node_modules incluso),
  ;; o registro falha ("no file descriptor left") e o astro-ls morre com exit 1.
  ;; Aceita o registro sem observar nada. Para testar se ainda e preciso: comente
  ;; os dois cl-defmethod abaixo e abra um .astro; se o servidor cair, restaure.
  (cl-defmethod eglot-register-capability :around
    (_server (_method (eql workspace/didChangeWatchedFiles)) _id &rest _args)
    nil)
  (cl-defmethod eglot-unregister-capability :around
    (_server (_method (eql workspace/didChangeWatchedFiles)) _id &rest _args)
    nil))

(use-package eglot-typescript-preset
  :demand t
  :custom
  ;; The preset handles the Astro tsdk path itself; no manual server entry needed.
  ;; Default is 'rass, which requires rassumfrassum to be installed,
  ;; so use the standalone servers instead.
  (eglot-typescript-preset-astro-lsp-server 'astro-ls)
  (eglot-typescript-preset-css-lsp-server 'vscode-css-language-server))

(defun my/eglot-format-on-save ()
  "Formata o buffer ao salvar, se o Eglot estiver ativo e o servidor formatar.
A checagem acontece na hora de salvar, nao quando o Eglot conecta."
  (when (and (eglot-managed-p)
             (eglot-server-capable :documentFormattingProvider))
    (condition-case err
        (eglot-format-buffer)
      (error (message "Eglot: formatacao falhou: %s" (error-message-string err))))))

(add-hook 'eglot-managed-mode-hook
          (lambda () (add-hook 'before-save-hook #'my/eglot-format-on-save nil t)))

;; ==========================================
;; 9.5 WHICH-KEY
;; ==========================================
(use-package which-key
  :ensure nil
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-side-window-location 'bottom))

;; ==========================================
;; 10. LEADER KEY (SPC) - estilo Doom/Spacemacs
;; ==========================================
(defvar my-leader-map (make-sparse-keymap) "Leader keymap bound to SPC.")

(defun my/leader (&rest bindings)
  "Define BINDINGS (TECLAS COMANDO ...) em `my-leader-map'."
  (while bindings
    (define-key my-leader-map (kbd (pop bindings)) (pop bindings))))

(with-eval-after-load 'evil
  (define-key evil-motion-state-map (kbd "SPC") my-leader-map)
  (define-key evil-normal-state-map (kbd "SPC") my-leader-map)

  (my/leader
   ;; Acesso rapido
   "SPC" #'execute-extended-command   ; SPC SPC = M-x
   "."   #'find-file
   ","   #'consult-buffer
   "/"   #'consult-ripgrep             ; precisa: sudo port install ripgrep
   "d"   #'dired

   ;; Arquivos
   "f f" #'find-file
   "f r" #'consult-recent-file
   "f s" #'save-buffer
   "f j" #'dired-jump

   ;; Buffers
   "b b" #'consult-buffer
   "b k" #'kill-current-buffer
   "b n" #'next-buffer
   "b p" #'previous-buffer
   "b r" #'revert-buffer

   ;; Janelas
   "w v" #'evil-window-vsplit
   "w s" #'evil-window-split
   "w d" #'delete-window
   "w o" #'delete-other-windows
   "w w" #'other-window
   "w h" #'evil-window-left
   "w j" #'evil-window-down
   "w k" #'evil-window-up
   "w l" #'evil-window-right

   ;; Busca
   "s s" #'consult-line
   "s i" #'consult-imenu
   "s p" #'consult-ripgrep

   ;; Projetos
   "p p" #'projectile-switch-project
   "p f" #'projectile-find-file
   "p s" #'consult-ripgrep

   ;; Git
   "g g" #'magit-status
   "g l" #'magit-log-current
   "g b" #'magit-blame-addition
   "g c" #'magit-commit

   ;; Codigo / LSP
   "c r" #'eglot-rename
   "c a" #'eglot-code-actions
   "c f" #'eglot-format
   "c d" #'consult-flymake
   "c i" #'eglot-find-implementation

   ;; UI: fonte e zoom (global-text-scale-adjust le a ultima tecla: + - 0)
   "t f" #'my/set-font
   "t s" #'my/set-font-size
   "t +" #'global-text-scale-adjust
   "t -" #'global-text-scale-adjust
   "t 0" #'global-text-scale-adjust
   "t l" #'display-line-numbers-mode

   ;; Ajuda
   "h k" #'describe-key
   "h f" #'describe-function
   "h v" #'describe-variable
   "h m" #'describe-mode

   ;; Sair
   "q q" #'save-buffers-kill-terminal
   "q r" #'restart-emacs)

  ;; Fora do leader
  (define-key evil-motion-state-map (kbd "g r") #'xref-find-references)
  (define-key evil-motion-state-map (kbd "]d")  #'flymake-goto-next-error)
  (define-key evil-motion-state-map (kbd "[d")  #'flymake-goto-prev-error))

;; K mostra a documentacao (hover) quando o Eglot esta ativo no buffer.
(add-hook 'eglot-managed-mode-hook
          (lambda () (evil-local-set-key 'normal (kbd "K") #'eldoc-doc-buffer)))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "SPC b" "+buffer"
    "SPC c" "+code/lsp"
    "SPC f" "+file"
    "SPC g" "+git"
    "SPC h" "+help"
    "SPC p" "+project"
    "SPC q" "+quit"
    "SPC s" "+search"
    "SPC t" "+ui/font"
    "SPC w" "+window"))

;;; init.el ends here
