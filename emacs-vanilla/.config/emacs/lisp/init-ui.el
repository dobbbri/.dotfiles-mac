;;; init-ui.el -*- lexical-binding: t; -*-

;; --- Fonte --------------------------------------------------------------------
(let ((fonte (font-spec :family "Lekton Nerd Font Mono" :size 18 :weight 'normal)))
  (when (and (display-graphic-p) (find-font fonte))
    (set-face-attribute 'default nil :font fonte)
    (set-face-attribute 'variable-pitch nil :font fonte)))

;; --- Tema ---------------------------------------------------------------------
(use-package doom-themes
  :demand t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-peacock t)
  (doom-themes-org-config))

;; --- Ícones e modeline --------------------------------------------------------
(use-package nerd-icons :demand t)
(use-package doom-modeline
  :demand t
  :config
  (setq doom-modeline-height 24
        doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-mode 1))

;; --- Números de linha (relativos; use t para absolutos) -----------------------
(setq display-line-numbers-type 'relative)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))
;; O Org deriva de text-mode, mas fica sem números de linha.
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))

;; --- Pequenos auxílios visuais (hl-todo, ophints, nav-flash, vc-gutter) ----------
(use-package hl-todo
  :demand t
  :config (global-hl-todo-mode 1))

(use-package evil-goggles                     ; ophints do Doom
  :after evil
  :config
  (setq evil-goggles-duration 0.1)
  (evil-goggles-mode 1))

(use-package pulsar                           ; nav-flash do Doom
  :demand t
  :config
  (setq pulsar-delay 0.04 pulsar-iterations 8)
  (add-hook 'consult-after-jump-hook #'pulsar-pulse-line)
  (add-hook 'xref-after-jump-hook #'pulsar-pulse-line)
  (pulsar-global-mode 1))

(use-package diff-hl                          ; vc-gutter do Doom
  :demand t
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (with-eval-after-load 'magit
    (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

;; --- Workspaces (tab-bar no lugar do persp-mode) --------------------------------
(setq tab-bar-show 1
      tab-bar-close-button-show nil
      tab-bar-new-tab-choice "*scratch*")
(tab-bar-mode 1)

;; --- Popups (equivalente simples do módulo popup) -----------------------------
(setq display-buffer-alist
      `((,(rx bos "*" (or "Help" "helpful" "compilation" "Warnings" "Messages"
                          "Backtrace" "Occur" "grep" "xref" "Flycheck errors")
              (* any) "*")
         (display-buffer-in-side-window)
         (side . bottom) (slot . 0) (window-height . 0.35))))

(provide 'init-ui)
