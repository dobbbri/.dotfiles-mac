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
(column-number-mode 1)
(add-hook 'prog-mode-hook #'hl-line-mode)

;; MacPorts Emacs 31: avoid font-cache rendering freezes
(setq inhibit-compacting-font-caches t)

(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold 16777216)))

;; ==========================================
;; 1.5 macOS OPTION KEY AS META
;; ==========================================
(when (eq system-type 'darwin)
  (setq ns-option-modifier 'meta
        ns-right-option-modifier 'meta
        mac-option-modifier 'meta
        mac-right-option-modifier 'meta))

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
;; Icone do Astro (nf-dev-astro, U+E735): desenhado direto com a fonte Nerd,
;; sem depender de o nerd-icons conhecer esse nome. Cor: troque a face abaixo.
(defun my/nerd-icon-astro (&rest _)
  "Icone do Astro no formato esperado pelas tabelas do nerd-icons."
  (propertize "\ue735"
              'face (list :family nerd-icons-font-family :inherit 'nerd-icons-orange)
              'font-lock-face (list :family nerd-icons-font-family :inherit 'nerd-icons-orange)
              'rear-nonsticky t))

;; Na primeira vez baixa a fonte "Symbols Nerd Font Mono" (so em GUI).
;; Se os icones aparecerem como quadrados, reinicie o Emacs uma vez.
(use-package nerd-icons
  :config
  (when (and (display-graphic-p)
             (not (find-font (font-spec :name nerd-icons-font-family))))
    (nerd-icons-install-fonts t))
  ;; Arquivos .astro (dired, minibuffer, dashboard) e o modo astro-ts-mode (modeline)
  (add-to-list 'nerd-icons-extension-icon-alist '("astro" my/nerd-icon-astro))
  (add-to-list 'nerd-icons-mode-icon-alist '(astro-ts-mode my/nerd-icon-astro)))

(use-package nerd-icons-dired
  :after nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode)
  ;; Por padrao os icones do dired sao monocromaticos; nil = coloridos.
  :init (setq nerd-icons-dired-monochrome nil))

;; Icones nos candidatos do Vertico/Marginalia (arquivos, buffers, comandos).
(use-package nerd-icons-completion
  :after (marginalia nerd-icons)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

;; Icones (tipo do simbolo) no popup do Corfu.
(use-package nerd-icons-corfu
  :after (corfu nerd-icons)
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

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
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-lsp t)
  (doom-modeline-modal t)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-encoding nil)
  ;; ATENCAO: icones na modeline ja derrubaram o Emacs 31 do MacPorts (SIGSEGV em
  ;; fontset_font). Se voltar a fechar ao iniciar, mude para nil.
  (doom-modeline-icon t))

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
  ;; Escolher um projeto (SPC p p) abre a raiz dele no dired, sem menu de comandos.
  (projectile-switch-project-action #'projectile-dired)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  ;; ~/.emacs.d aparece em SPC p p e no dashboard, mesmo sem git.
  (projectile-add-known-project (file-name-as-directory (expand-file-name user-emacs-directory))))

;; ==========================================
;; 7. MAGIT
;; ==========================================
(use-package magit
  :commands magit-status
  :custom (magit-diff-refine-hunk t))

;; Marcadores de linhas alteradas na margem (git)
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (diff-hl-flydiff-mode 1))

;; ==========================================
;; 7.5 TERMINAL (EAT) E DASHBOARD
;; ==========================================
;; eat: terminal em Elisp puro, nao precisa compilar nada.
(use-package eat
  :defer t
  :custom (eat-kill-buffer-on-exit t))

(defun my/open-project-dired (dir)
  "Abre DIR (raiz do projeto) no dired e registra o projeto. Usado pelo dashboard."
  (let ((dir (file-name-as-directory (expand-file-name dir))))
    (dired dir)
    (projectile-add-known-project dir)))

;; Tela inicial: arquivos e projetos recentes
(use-package dashboard
  :custom
  (dashboard-items '((recents  . 8)     ; ultimos arquivos abertos
                     (projects . 6)))   ; ultimos projetos
  (dashboard-projects-backend 'projectile)
  (dashboard-projects-switch-function #'my/open-project-dired)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-center-content t)
  (dashboard-startup-banner 'logo)
  (dashboard-banner-logo-title "Emacs")
  (dashboard-set-footer nil)
  :config (dashboard-setup-startup-hook))

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
  :custom
  ;; Depuracao do loop de reconexao: nil mostra o erro real do servidor.
  ;; Depois que estabilizar, volte para 3 (padrao).
  (eglot-autoreconnect nil)
  :hook ((js-ts-mode typescript-ts-mode tsx-ts-mode css-ts-mode astro-ts-mode)
         . eglot-ensure)
  :config
  ;; O astro-ls pede client/registerCapability para didChangeWatchedFiles com o
  ;; glob "**/*.{js,ts,json,astro,...}". No macOS o Eglot usa kqueue (um
  ;; descritor por diretorio, node_modules inclusive), a ativacao falha com
  ;; "Internal error" e o astro-ls morre (rejeicao nao tratada, exit 1).
  ;; Aceita o registro sem observar nada: o servidor segue funcionando.
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

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (when (eglot-server-capable :documentFormattingProvider)
              (add-hook 'before-save-hook #'eglot-format-buffer nil t))))

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

   ;; Abrir
   "o t" #'eat

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
    "SPC o" "+open"
    "SPC p" "+project"
    "SPC q" "+quit"
    "SPC s" "+search"
    "SPC t" "+ui/font"
    "SPC w" "+window"))

;;; init.el ends here
