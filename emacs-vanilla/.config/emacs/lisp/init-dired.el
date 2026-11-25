;;; init-dired.el -*- lexical-binding: t; -*-

;; Dired, Dirvish (inclusive o TAB) e vertico com a mesma ordem: por nome (código de
;; caractere, como o `ls'), pastas primeiro, sem `-v'. No macOS exige o gls
;; (coreutils); no Linux o `ls' já é o GNU.
(defconst my/ls-switches "-ahl --group-directories-first")

(defconst my/gnu-ls-p
  (or (executable-find "gls")
      (eq system-type 'gnu/linux))
  "Non-nil se há um `ls' GNU disponível.")

(when (and (eq system-type 'darwin) (executable-find "gls"))
  (setq insert-directory-program "gls"
        dired-use-ls-dired t))

(use-package dired
  :ensure nil
  :hook (dired-mode . dired-omit-mode)     ; como no Doom, omite arquivos "ruído"
  :config
  (setq dired-dwim-target t
        dired-recursive-copies 'always
        dired-recursive-deletes 'top
        dired-kill-when-opening-new-dired-buffer t
        dired-auto-revert-buffer #'dired-directory-changed-p)
  (when my/gnu-ls-p
    (setq dired-listing-switches my/ls-switches)))

(use-package dirvish
  :after dired
  :demand t
  :config
  (when my/gnu-ls-p
    (setq dirvish-subtree-listing-switches my/ls-switches))
  (setq dirvish-attributes '(nerd-icons file-size)
        dirvish-use-header-line t)
  (dirvish-override-dired-mode 1))

(provide 'init-dired)
