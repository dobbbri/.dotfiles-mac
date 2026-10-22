;;; init.el --- Emacs vanilla moderno: tree-sitter + eglot + evil -*- lexical-binding: t; -*-

;; Requer Emacs 31+ (usa treesit-enabled-modes e treesit-auto-install-grammar).
;; Coloque early-init.el ao lado deste arquivo, em ~/.emacs.d/.
;;
;; Binários externos (servidores LSP, formatadores, rg/fd):
;;   bash install-deps.sh   (MacPorts + nvm/npm; `bash install-deps.sh --check` verifica)
;;   O coreutils do MacPorts fornece o `gls`, usado pelo dired no macOS.

;;;; ------------------------------------------------------------
;;;; Pacotes
;;;; ------------------------------------------------------------
;; Compatibilidade com o Emacs 31: `treesit-ready-p' não existe mais, mas alguns
;; pacotes ainda a chamam nos seus autoloads (erro "void-function treesit-ready-p").
;; Definimos um substituto ANTES de carregar os pacotes.
(unless (fboundp 'treesit-ready-p)
  (defun treesit-ready-p (language &optional _quiet)
    "Substituto de compatibilidade: non-nil se a gramática de LANGUAGE está disponível."
    (and (fboundp 'treesit-language-available-p)
         (treesit-language-available-p language))))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setopt use-package-always-ensure t)

;; Mantém o init.el limpo: o Customize escreve em outro arquivo
(setopt custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

;; ~/.emacs.d organizado: só a configuração fica na raiz; dados de uso (recentes,
;; histórico, cache...) vão para var/ e arquivos de apoio para etc/.
;; Precisa carregar ANTES dos pacotes que gravam estado (recentf, savehist...).
(use-package no-littering
  :demand t
  :config
  ;; nomes fixos, para o migrate-emacs-d.sh saber para onde mover os arquivos antigos
  (setq recentf-save-file      (no-littering-expand-var-file-name "recentf.eld")
        savehist-file          (no-littering-expand-var-file-name "savehist.el")
        save-place-file        (no-littering-expand-var-file-name "saveplace.el")
        project-list-file      (no-littering-expand-var-file-name "projects.eld"))
  ;; arquivos de estado não entram na lista de recentes
  (with-eval-after-load 'recentf
    (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
    (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory))))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :init
  ;; Shell de login SEM modo interativo: não lê o ~/.zshrc (onde o nvm costuma
  ;; ser carregado, o que deixava o boot ~2s mais lento). O PATH vem do ~/.zprofile.
  (setopt exec-path-from-shell-arguments '("-l"))
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

;;;; Temas
;; doom-themes traz dezenas de temas (doom-one, doom-gruvbox, doom-nord,
;; doom-tokyo-night, doom-dracula...). catppuccin e gruvbox são coleções à parte.
;; Troque de tema na hora com SPC t t (consult-theme).
(defvar my/theme 'doom-one
  "Tema carregado na inicialização.")

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme my/theme t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package catppuccin-theme
  :defer t
  :init (setq catppuccin-flavor 'macchiato)) ; latte, frappe, macchiato ou mocha

(use-package gruvbox-theme
  :defer t)

;; Fonte: tamanho 16 (altura em décimos de ponto: 160 = 16pt).
;; O tamanho vale mesmo que a JetBrains Mono não esteja instalada.
(defvar my/font-height 160
  "Altura da fonte padrão (160 = 16pt).")
(set-face-attribute 'default nil :height my/font-height)
(when (find-font (font-spec :name "JetBrains Mono"))
  (set-face-attribute 'default nil :family "JetBrains Mono"))

;; Abrir maximizado. No macOS o parâmetro do early-init.el às vezes é ignorado,
;; então reforçamos depois que a janela está pronta (window-setup-hook).
(add-hook 'window-setup-hook
          (lambda ()
            (when (display-graphic-p)
              (set-frame-parameter nil 'fullscreen 'maximized)))
          90)

;; ---- Dotfiles e node_modules -------------------------------------------
;; node_modules fica SEMPRE oculto (find-file, projetos e dired).
;; Dotfiles ficam ocultos por padrão; alterne com SPC t . (my/toggle-dotfiles).
(defvar my/show-dotfiles nil
  "Se não-nil, mostra dotfiles em find-file, projetos e dired.")

;; Também acelera o project-find-file em projetos sem git (não varre node_modules)
(add-to-list 'vc-directory-exclusion-list "node_modules")

(defun my/dired-omit-regexp ()
  "Regexp dos arquivos que o dired deve omitir, conforme `my/show-dotfiles'."
  (concat "\\`[.]?#\\|\\`[.][.]?\\'\\|\\`node_modules\\'"
          (unless my/show-dotfiles "\\|\\`[.][^.]")))

(defun my/toggle-dotfiles ()
  "Mostra/oculta dotfiles em find-file, projetos e dired (node_modules segue oculto)."
  (interactive)
  (setq my/show-dotfiles (not my/show-dotfiles))
  (setq dired-omit-files (my/dired-omit-regexp))
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (derived-mode-p 'dired-mode)
        (revert-buffer))))
  (message "Dotfiles: %s" (if my/show-dotfiles "visíveis" "ocultos")))

(defun my/toggle-dotfiles-in-minibuffer ()
  "Alterna dotfiles sem sair do prompt e atualiza a lista de candidatos na hora."
  (interactive)
  (my/toggle-dotfiles)
  ;; força o Vertico a recalcular os candidatos (variável interna do Vertico)
  (when (boundp 'vertico--input)
    (setq vertico--input nil)))

;; Dired decente no macOS (usa gls do coreutils)
(use-package dired
  :ensure nil
  :hook (dired-mode . dired-hide-details-mode)   ; só os nomes; ( alterna os detalhes
  :custom
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-dwim-target t)                 ; sugere a pasta do outro dired aberto como destino
  (dired-create-destination-dirs 'ask)  ; ao copiar/mover, oferece criar a pasta de destino
  :config
  (when-let* ((gls (executable-find "gls")))
    (setopt insert-directory-program gls
            dired-use-ls-dired t
            dired-listing-switches "-alh --group-directories-first")))

;; Árvore no próprio dired: TAB expande/recolhe a pasta sob o cursor (ver teclas no fim)
(use-package dired-subtree
  :after dired
  :custom (dired-subtree-use-backgrounds nil)
  :config
  ;; os ícones das linhas inseridas precisam ser desenhados de novo
  (add-hook 'dired-subtree-after-insert-hook
            (lambda ()
              (when (and (bound-and-true-p nerd-icons-dired-mode)
                         (fboundp 'nerd-icons-dired--refresh))
                (nerd-icons-dired--refresh)))))

;; dired-omit-mode esconde dotfiles e node_modules na listagem
(use-package dired-x
  :ensure nil
  :after dired
  :hook (dired-mode . dired-omit-mode)
  :custom (dired-omit-files (my/dired-omit-regexp)))

;;;; ------------------------------------------------------------
;;;; Completion: vertico + orderless + marginalia + consult + embark + corfu
;;;; ------------------------------------------------------------
(use-package vertico
  :init (vertico-mode)
  :custom (vertico-cycle t)
  :bind (:map vertico-map
         ("M-." . my/toggle-dotfiles-in-minibuffer)))

;; Ordem alfabética (sem diferenciar maiúsculas e acentos) para arquivos e projetos,
;; escondendo node_modules e (opcionalmente) dotfiles. Por padrão o Vertico ordena
;; por histórico e tamanho, o que parece "bagunçado".
;; Comandos (M-x), buffers etc. continuam ordenados por uso recente.
(defvar my/emacs-d-storage-dirs
  '("elpa" "eln-cache" "var" "tree-sitter" "auto-save-list" "transient")
  "Pastas de dados dentro de ~/.emacs.d, ocultas nas listagens (só a configuração aparece).")

(defun my/dot-part-p (part)
  "Non-nil se PART é um nome oculto (começa com ponto), exceto ., .. e .emacs.d."
  (and (string-prefix-p "." part)
       (not (member part '("." ".." ".emacs.d")))))

(defun my/typing-dot-p ()
  "Non-nil se o último componente digitado no minibuffer começa com ponto."
  (and (minibufferp)
       (string-prefix-p "." (file-name-nondirectory (minibuffer-contents-no-properties)))))

(defun my/in-emacs-d-listing-p (deep)
  "Non-nil se a listagem atual é de dentro de ~/.emacs.d.
DEEP: arquivos de um projeto (vale o `default-directory'); senão, a pasta
que está sendo navegada no find-file (precisa ser a raiz de ~/.emacs.d)."
  (and (minibufferp)
       (let ((root (expand-file-name user-emacs-directory))
             (dir (expand-file-name
                   (if deep
                       default-directory
                     (or (file-name-directory (minibuffer-contents-no-properties))
                         default-directory)))))
         (if deep
             (string-prefix-p root dir)
           (string= (file-name-as-directory dir) root)))))

(defun my/hidden-candidate-p (cand show-dots deep emacs-d)
  "Non-nil se CAND deve ficar oculto.
DEEP: confere todos os componentes do caminho (arquivos do projeto);
senão, só o nome simples (listagem de um diretório).
EMACS-D: a listagem é de ~/.emacs.d, então pastas de dados também ficam ocultas."
  (let ((parts (split-string cand "/" t)))
    (or (member "node_modules" parts)
        (and emacs-d parts (member (car parts) my/emacs-d-storage-dirs))
        (and (not show-dots)
             (if deep
                 (seq-some #'my/dot-part-p parts)
               (and parts (null (cdr parts)) (my/dot-part-p (car parts))))))))

(defun my/remove-hidden (candidates deep)
  "Remove de CANDIDATES o que deve ficar oculto (ver `my/hidden-candidate-p')."
  (let ((show-dots (or my/show-dotfiles (my/typing-dot-p)))
        (emacs-d (my/in-emacs-d-listing-p deep)))
    (seq-remove (lambda (c) (my/hidden-candidate-p c show-dots deep emacs-d)) candidates)))

(defun my/sort-plain (candidates)
  "Ordena CANDIDATES alfabeticamente, ignorando caixa e acentos."
  (sort candidates (lambda (a b) (string-collate-lessp a b nil t))))

(defun my/sort-dirs-first (candidates)
  "Arquivos de um diretório: filtra, ordena e põe os diretórios (com /) primeiro."
  (let ((sorted (my/sort-plain (my/remove-hidden candidates nil))))
    (nconc (seq-filter (lambda (x) (string-suffix-p "/" x)) sorted)
           (seq-remove (lambda (x) (string-suffix-p "/" x)) sorted))))

(defun my/sort-project-files (candidates)
  "Arquivos/diretórios de um projeto: filtra e ordena alfabeticamente."
  (my/sort-plain (my/remove-hidden candidates t)))

(use-package vertico-multiform
  :ensure nil
  :after vertico
  :custom
  (vertico-multiform-categories
   '((file         (vertico-sort-function . my/sort-dirs-first))
     (project-file (vertico-sort-function . my/sort-project-files))))
  (vertico-multiform-commands
   '((project-switch-project (vertico-sort-function . my/sort-plain))
     (project-find-dir       (vertico-sort-function . my/sort-project-files))))
  :config (vertico-multiform-mode 1))

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
;;;; Ícones (nerd-icons)
;;;; ------------------------------------------------------------
;; Na primeira vez, baixa a fonte "Symbols Nerd Font Mono" (só em GUI).
;; Se os ícones aparecerem como quadrados, reinicie o Emacs uma vez.
;; Ícone do Astro (nf-dev-astro, U+E735): desenhado direto com a fonte Nerd, sem
;; depender de o nerd-icons conhecer esse nome. Troque a cor mudando a face.
(defun my/nerd-icon-astro (&rest _)
  "Ícone do Astro no formato esperado pelas tabelas do nerd-icons."
  (propertize "\ue735"
              'face (list :family nerd-icons-font-family :inherit 'nerd-icons-orange)
              'font-lock-face (list :family nerd-icons-font-family :inherit 'nerd-icons-orange)
              'rear-nonsticky t))

(use-package nerd-icons
  :config
  (when (and (display-graphic-p)
             (not (find-font (font-spec :name nerd-icons-font-family))))
    (nerd-icons-install-fonts t))
  ;; Arquivos .astro (dired, minibuffer, dashboard) e o modo astro-ts-mode (modeline)
  (add-to-list 'nerd-icons-extension-icon-alist '("astro" my/nerd-icon-astro))
  (add-to-list 'nerd-icons-mode-icon-alist '(astro-ts-mode my/nerd-icon-astro)))

;; Ícones nos candidatos do minibuffer (vertico + marginalia)
(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; Ícones de tipo (função, variável, classe...) no popup do corfu
(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Ícones por tipo de arquivo no dired
(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode)
  ;; Por padrão os ícones do dired são monocromáticos; nil = ícones coloridos.
  :init (setq nerd-icons-dired-monochrome nil))

;;;; ------------------------------------------------------------
;;;; Modeline
;;;; ------------------------------------------------------------
(column-number-mode 1)
(add-hook 'prog-mode-hook #'hl-line-mode)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-icon t)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-encoding nil))

;;;; ------------------------------------------------------------
;;;; Dashboard (tela inicial: arquivos e projetos recentes)
;;;; ------------------------------------------------------------
;; ~/.emacs.d é tratado como projeto (mesmo sem git): o early-init.el marca a raiz.
;; Assim ele pode ser listado e selecionado em SPC p p e no dashboard.
(setopt project-vc-extra-root-markers '("early-init.el"))

;; Escolher um projeto (SPC p p) abre a raiz dele no dired, sem menu de comandos.
;; Para achar arquivos dentro do projeto: SPC SPC (project-find-file).
(setopt project-switch-commands #'project-dired)

(defun my/open-project-dired (dir)
  "Abre DIR (raiz do projeto) no dired e registra o projeto. Usado pelo dashboard."
  (let ((dir (file-name-as-directory (expand-file-name dir))))
    (dired dir)
    (when-let* ((pr (project-current nil dir)))
      (project-remember-project pr))))
(add-hook 'emacs-startup-hook
          (lambda ()
            (when-let* ((pr (project-current nil user-emacs-directory)))
              (project-remember-project pr))))

(use-package dashboard
  :custom
  (dashboard-items '((recents  . 8)     ; últimos arquivos abertos
                     (projects . 6)))   ; últimos projetos
  (dashboard-projects-backend 'project-el)
  (dashboard-projects-switch-function #'my/open-project-dired)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-center-content t)
  (dashboard-startup-banner 'logo)
  (dashboard-banner-logo-title "Emacs")
  (dashboard-set-footer nil)
  :config (dashboard-setup-startup-hook))

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
;;;; Terminal (eat: Elisp puro, não precisa compilar nada)
;;;; ------------------------------------------------------------
(use-package eat
  :defer t
  :custom (eat-kill-buffer-on-exit t))

;;;; ------------------------------------------------------------
;;;; Tree-sitter
;;;; ------------------------------------------------------------
(setopt treesit-font-lock-level 4)

;; Emacs 31: se faltar a gramática, oferece baixar e compilar ao abrir o arquivo
;; ('ask é o padrão; use 'always para instalar sem perguntar).
(setopt treesit-auto-install-grammar 'ask)

;; Emacs 31: troca automaticamente cada modo pela variante tree-sitter
;; (sh-mode -> bash-ts-mode, js-mode -> js-ts-mode, etc.).
(setopt treesit-enabled-modes t)

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
;; Emacs 30+: o backend elisp-flymake-byte-compile só roda em conteúdo "confiável".
;; Marcamos como confiável a sua pasta de configuração; o *scratch* fica de fora.
(when (boundp 'trusted-content)
  (add-to-list 'trusted-content (abbreviate-file-name (file-name-as-directory user-emacs-directory))))

(defun my/flymake-maybe ()
  "Liga o flymake, exceto em buffers Elisp sem arquivo (ex.: *scratch*, não confiáveis)."
  (unless (and (derived-mode-p 'emacs-lisp-mode) (not buffer-file-name))
    (flymake-mode 1)))

(use-package flymake
  :ensure nil
  :hook (prog-mode . my/flymake-maybe)
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

(defun my/tsdk-valid-p (dir)
  "Non-nil se DIR contém typescript.js ou tsserverlibrary.js (o que o astro-ls exige)."
  (and dir
       (or (file-exists-p (expand-file-name "typescript.js" dir))
           (file-exists-p (expand-file-name "tsserverlibrary.js" dir)))))

(defun my/tsdk ()
  "Diretório lib do TypeScript para o astro-ls.
Usa o do projeto se for válido; senão, cai para o TypeScript global."
  (let* ((root (locate-dominating-file default-directory "node_modules/typescript"))
         (local (and root (expand-file-name "node_modules/typescript/lib" root)))
         (global (when-let* ((tsc (executable-find "tsc")))
                   ;; .../typescript/bin/tsc  ->  .../typescript/lib
                   (expand-file-name "../lib" (file-name-directory (file-truename tsc))))))
    (cond ((my/tsdk-valid-p local) local)
          ((my/tsdk-valid-p global)
           (message "astro-ls: typescript do projeto ausente/inválido; usando o global (%s)" global)
           global)
          (t (message "astro-ls: nenhum typescript.js encontrado (projeto: %s, global: %s)" local global)
             (or local global "")))))

;; Tailwind junto com ts_ls/astro-ls exige multiplexar servidores (Eglot 31 + rass).
;; Instale o `rass` (bash install-deps.sh --with-rass) e ligue com SPC t r.
(defvar my/use-rass nil
  "Se não-nil e `rass' estiver no PATH, combina o servidor principal + tailwindcss.")

(defun my/with-tailwind (cmd)
  (if (and my/use-rass (executable-find "rass"))
      `("rass" "--" ,@cmd "--" "tailwindcss-language-server" "--stdio")
    cmd))

(defun my/toggle-rass ()
  "Liga/desliga o rass (Tailwind junto com ts_ls/astro-ls) e reinicia o eglot."
  (interactive)
  (when (and (not my/use-rass) (not (executable-find "rass")))
    (user-error "rass não encontrado no PATH (rode: bash install-deps.sh --with-rass)"))
  (setq my/use-rass (not my/use-rass))
  (message "rass: %s" (if my/use-rass "ligado (Tailwind ativo)" "desligado"))
  ;; eglot-reconnect reusaria o comando antigo, então desligamos e iniciamos de novo
  (when-let* ((server (and (fboundp 'eglot-current-server) (eglot-current-server))))
    (eglot-shutdown server)
    (call-interactively #'eglot)))

(defun my/check-completion ()
  "Abre um relatório sobre o LSP e o autocompletar do buffer atual.
Serve para depurar quando o completion não aparece (ex.: em arquivos .astro)."
  (interactive)
  (let* ((buf (current-buffer))
         (server (and (fboundp 'eglot-current-server) (eglot-current-server)))
         (local (remq t completion-at-point-functions))
         (chain (append local (default-value 'completion-at-point-functions)))
         (report
          (list
           (format "major-mode ............ %s" major-mode)
           (format "arquivo ............... %s" (or buffer-file-name "(sem arquivo)"))
           (format "eglot conectado ....... %s" (if server "sim" "NÃO"))
           (format "completionProvider .... %S"
                   (if server (eglot-server-capable :completionProvider) "(sem servidor)"))
           (format "1ª fonte completion ... %s" (or (car chain) "nenhuma"))
           (format "cadeia de fontes ...... %S" chain)
           (format "diagnósticos (flymake)  %s"
                   (if (bound-and-true-p flymake-mode)
                       (length (flymake-diagnostics))
                     "flymake desligado"))
           (format "astro-ls no PATH ...... %s" (or (executable-find "astro-ls") "NÃO ENCONTRADO"))
           (format "node no PATH .......... %s" (or (executable-find "node") "NÃO ENCONTRADO"))
           (format "eglot-ensure no hook .. %s"
                   (if (and (boundp 'astro-ts-mode-hook) (memq 'eglot-ensure astro-ts-mode-hook))
                       "sim" "não"))
           (format "servidor escolhido .... %s"
                   (condition-case err
                       (format "%S" (nth 3 (eglot--guess-contact)))
                     (error (format "ERRO: %s" (error-message-string err)))))
           (format "tsdk (astro-ls) ....... %s" (my/tsdk))
           (format "gramática astro ....... %s"
                   (if (fboundp 'treesit-language-available-p)
                       (treesit-language-available-p 'astro)
                     "?")))))
    (with-current-buffer (get-buffer-create "*Diagnóstico LSP*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (string-join report "\n") "\n\n"
                "Dica: em .astro, digite console. no frontmatter (entre as linhas ---)\n"
                "e aperte C-M-i. Feche este buffer com q.\n"))
      (special-mode)
      (setq-local default-directory (buffer-local-value 'default-directory buf)))
    (pop-to-buffer "*Diagnóstico LSP*")))

(defun my/eglot-toggle-log ()
  "Liga/desliga o log das mensagens LSP (`eglot-events-buffer'); vale após reconectar.
Fica desligado por padrão para não gastar memória."
  (interactive)
  (let ((on (zerop (or (plist-get eglot-events-buffer-config :size) 0))))
    (setopt eglot-events-buffer-config
            (if on '(:size 2000000 :format full) '(:size 0)))
    (message "Log do eglot: %s (rode M-x eglot-reconnect e depois M-x eglot-events-buffer)"
             (if on "ligado" "desligado"))))

;; O Eglot já conhece bash-language-server, vscode-json-language-server e
;; lua-language-server (com os language-ids corretos). Só sobrescrevemos o que
;; precisa de lógica própria: o tsserver (Tailwind via rass) e o astro-ls.
(with-eval-after-load 'eglot
  ;; Os :language-id precisam ser mantidos: é por eles que o tsserver distingue JS, TS e TSX.
  (setf (alist-get '((js-ts-mode :language-id "javascript")
                     (tsx-ts-mode :language-id "typescriptreact")
                     (typescript-ts-mode :language-id "typescript"))
                   eglot-server-programs nil nil #'equal)
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
  ;; prettier GLOBAL (usado quando o projeto não tem o seu; ver my/pick-prettier abaixo)
  (setf (alist-get 'prettier-global apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
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

;; ---- Prettier: usa o do projeto; se não houver, usa o global ---------------
;; shfmt, stylua, taplo e yamlfmt já são binários globais, então só o prettier
;; (que costuma ficar em node_modules) precisa dessa lógica.
(require 'subr-x)

(defvar my/global-node-modules nil
  "Cache do diretório de pacotes npm globais (saída de `npm root -g').")

(defun my/global-node-modules ()
  "Diretório de pacotes npm globais, ou nil se não houver npm."
  (or my/global-node-modules
      (setq my/global-node-modules
            (when (executable-find "npm")
              (string-trim (shell-command-to-string "npm root -g 2>/dev/null"))))))

(defun my/local-node-p (relative-path)
  "Non-nil se node_modules/RELATIVE-PATH existe acima do arquivo atual."
  (locate-dominating-file default-directory (concat "node_modules/" relative-path)))

(defun my/global-astro-plugin ()
  "Arquivo de entrada do prettier-plugin-astro instalado globalmente, ou nil."
  (when-let* ((root (my/global-node-modules))
              (dir (expand-file-name "prettier-plugin-astro" root))
              ((file-directory-p dir)))
    (let* ((pkg (expand-file-name "package.json" dir))
           (main (or (and (file-exists-p pkg)
                          (alist-get 'main (json-parse-file pkg :object-type 'alist)))
                     "dist/index.js"))
           (entry (expand-file-name main dir)))
      (and (file-exists-p entry) entry))))

(defun my/pick-prettier ()
  "Escolhe o prettier do projeto se existir; senão, cai para o global.
Em arquivos Astro, o projeto precisa ter o prettier E o prettier-plugin-astro."
  (let* ((astro (derived-mode-p 'astro-ts-mode))
         (project-ok (and (my/local-node-p ".bin/prettier")
                          (or (not astro) (my/local-node-p "prettier-plugin-astro"))))
         (global (executable-find "prettier")))
    (cond
     (project-ok nil)                   ; mantém o padrão (apheleia-npx, local)
     ((not global) nil)                 ; sem prettier global: deixa o padrão
     (astro
      (when-let* ((plugin (my/global-astro-plugin)))
        (setf (alist-get 'prettier-astro-global apheleia-formatters)
              `("prettier" "--stdin-filepath" filepath
                "--plugin" ,plugin "--parser" "astro"))
        (setq-local apheleia-formatter 'prettier-astro-global)))
     (t (setq-local apheleia-formatter 'prettier-global)))))

(dolist (hook '(astro-ts-mode-hook js-ts-mode-hook typescript-ts-mode-hook
                tsx-ts-mode-hook json-ts-mode-hook))
  (add-hook hook #'my/pick-prettier))

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
      evil-vsplit-window-right t
      ;; formato do cursor por estado (como no Vim)
      evil-normal-state-cursor  '(box)
      evil-insert-state-cursor  '(bar)
      evil-visual-state-cursor  '(hollow)
      evil-replace-state-cursor '(hbar)
      evil-emacs-state-cursor   '(box))

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
  :init
  ;; O evil-collection ocupa SPC e , em dired/magit/help; liberamos para o leader.
  ;; Precisa ser definido antes do evil-collection-init.
  (setq evil-collection-key-blacklist '("SPC" ","))
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
    (kbd "<leader>fn") #'dired-create-empty-file   ; novo arquivo vazio na pasta atual
    (kbd "<leader>fN") #'make-directory            ; nova pasta
    ;; Buffers
    (kbd "<leader>bb") #'consult-buffer
    (kbd "<leader>bd") #'kill-current-buffer
    (kbd "<leader>bh") #'dashboard-open
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
    (kbd "<leader>cc") #'my/check-completion      ; o autocompletar usa o LSP?
    (kbd "<leader>cl") #'my/eglot-toggle-log      ; log das mensagens LSP (depuração)
    ;; Toggle
    (kbd "<leader>tt") #'consult-theme
    (kbd "<leader>tl") #'display-line-numbers-mode
    (kbd "<leader>t.") #'my/toggle-dotfiles
    (kbd "<leader>tr") #'my/toggle-rass
    ;; Abrir
    (kbd "<leader>ot") #'eat-project
    (kbd "<leader>oT") #'eat
    ;; Ajuda e sair
    (kbd "<leader>h")  help-map
    (kbd "<leader>qq") #'save-buffers-kill-terminal
    ;; Navegação estilo LSP
    (kbd "gd") #'xref-find-definitions
    (kbd "gr") #'xref-find-references
    (kbd "K")  #'eldoc-doc-buffer
    (kbd "]d") #'flymake-goto-next-error
    (kbd "[d") #'flymake-goto-prev-error)

  ;; No dired: g . mostra/oculta dotfiles (como no Doom Emacs)
  (with-eval-after-load 'dired
    (evil-define-key 'normal dired-mode-map
      "g."           #'my/toggle-dotfiles
      (kbd "TAB")    #'dired-subtree-toggle   ; expande/recolhe a pasta sob o cursor
      (kbd "<backtab>") #'dired-subtree-cycle ; S-TAB: expande por níveis
      "gu"           #'dired-subtree-up))     ; sobe para a pasta que contém o item

  (which-key-add-key-based-replacements
    "SPC f" "arquivos"
    "SPC b" "buffers"
    "SPC w" "janelas"
    "SPC s" "busca"
    "SPC p" "projeto"
    "SPC g" "git"
    "SPC c" "código"
    "SPC t" "toggle"
    "SPC o" "abrir"
    "SPC h" "ajuda"
    "SPC q" "sair"))

(provide 'init)
;;; init.el ends here
