;;; init-evil.el -*- lexical-binding: t; -*-

;; Precisa vir antes de carregar o evil, para o evil-collection assumir as teclas.
(setq evil-want-integration t
      evil-want-keybinding nil
      evil-want-C-u-scroll t
      evil-want-Y-yank-to-eol t
      evil-want-fine-undo t
      evil-respect-visual-line-mode t
      evil-split-window-below t
      evil-vsplit-window-right t
      evil-ex-visual-char-range t
      evil-kill-on-visual-paste nil
      evil-undo-system 'undo-fu)

(use-package undo-fu :demand t)
(use-package undo-fu-session
  :demand t
  :config
  (setq undo-fu-session-directory (expand-file-name "undo-fu-session/" my/var-dir))
  (undo-fu-session-global-mode 1))

(use-package evil
  :demand t
  :config
  (evil-mode 1)
  ;; Linhas quebradas visualmente: j/k andam por linha visual.
  (evil-define-key '(normal visual motion) 'global
    "j" #'evil-next-visual-line
    "k" #'evil-previous-visual-line))

(use-package evil-collection               ; (evil +everywhere)
  :after evil
  :config
  (setq evil-collection-setup-minibuffer nil)
  (evil-collection-init))

(use-package evil-escape                   ; "jk" sai do modo insert
  :after evil
  :config
  (setq evil-escape-key-sequence "jk"
        evil-escape-delay 0.15)
  (evil-escape-mode 1))

(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))

(use-package evil-nerd-commenter           ; gc comenta (como no Doom)
  :after evil
  :config
  (evil-define-key '(normal visual) 'global "gc" #'evilnc-comment-operator))

(provide 'init-evil)
