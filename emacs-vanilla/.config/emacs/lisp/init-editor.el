;;; init-editor.el -*- lexical-binding: t; -*-

;; --- Pares de delimitadores (default +smartparens) -----------------------------
(use-package smartparens
  :demand t
  :config
  (require 'smartparens-config)
  (smartparens-global-mode 1))

;; --- Snippets -------------------------------------------------------------------
(use-package yasnippet
  :demand t
  :config (yas-global-mode 1))
(use-package yasnippet-snippets :after yasnippet)

;; --- Fold (hideshow; `za', `zo', `zc' do evil usam o hideshow) ------------------
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; --- Checagem de sintaxe ---------------------------------------------------------
(use-package flycheck
  :hook ((prog-mode text-mode) . flycheck-mode)
  :config
  (setq flycheck-emacs-lisp-load-path 'inherit
        flycheck-indication-mode 'right-fringe)
  ;; Quem faz o lint é o Biome.
  (add-to-list 'flycheck-disabled-checkers 'javascript-eslint))

;; O *scratch* não tem checker de sintaxe: evita o aviso do flycheck.
(add-hook 'lisp-interaction-mode-hook (lambda () (flycheck-mode -1)))

;; --- Avaliação de elisp com overlay (eval +overlay) ------------------------------
(use-package eros
  :hook (emacs-lisp-mode . eros-mode))

;; --- Git -------------------------------------------------------------------------
(use-package magit
  :commands (magit-status magit-blame-addition magit-log-current magit-diff-unstaged)
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; --- Terminal ----------------------------------------------------------------------
;; O vterm compila um módulo nativo: precisa de cmake e libtool
;; (macOS: `sudo port install cmake libtool'; Fedora: `sudo dnf install cmake libtool').
(use-package vterm
  :commands vterm
  :config (setq vterm-max-scrollback 10000))

;; --- ibuffer / ajuda ------------------------------------------------------------------
(global-set-key [remap list-buffers] #'ibuffer)

(provide 'init-editor)
