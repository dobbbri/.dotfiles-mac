;;; init-core.el -*- lexical-binding: t; -*-

;; --- Arquivos gerados fora da pasta da config --------------------------------
(defconst my/var-dir (expand-file-name "var/" user-emacs-directory))
(make-directory my/var-dir t)

(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" my/var-dir)))
      auto-save-list-file-prefix (expand-file-name "auto-save/" my/var-dir)
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" my/var-dir) t))
      create-lockfiles nil
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 3
      kept-old-versions 1)
(make-directory (expand-file-name "backups/" my/var-dir) t)
(make-directory (expand-file-name "auto-save/" my/var-dir) t)

;; --- GC / desempenho ----------------------------------------------------------
(use-package gcmh
  :demand t
  :config (gcmh-mode 1))

(setq read-process-output-max (* 1024 1024)   ; LSP lê saídas grandes
      bidi-inhibit-bpa t
      bidi-paragraph-direction 'left-to-right
      fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t)

;; --- Comportamento geral ------------------------------------------------------
(setq use-short-answers t
      ring-bell-function #'ignore
      sentence-end-double-space nil
      require-final-newline t
      indent-tabs-mode nil
      tab-width 4
      fill-column 80
      scroll-conservatively 101
      scroll-margin 2
      scroll-preserve-screen-position t
      auto-revert-verbose nil
      global-auto-revert-non-file-buffers t
      vc-follow-symlinks t
      save-interprogram-paste-before-kill t
      help-window-select t)

(global-auto-revert-mode 1)
(delete-selection-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(pixel-scroll-precision-mode 1)
(electric-indent-mode 1)

(setq recentf-save-file (expand-file-name "recentf" my/var-dir)
      recentf-max-saved-items 300
      savehist-file (expand-file-name "savehist" my/var-dir)
      save-place-file (expand-file-name "saveplace" my/var-dir)
      history-length 1000)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)

(use-package which-key
  :ensure nil
  :demand t
  :config
  (setq which-key-idle-delay 0.4
        which-key-sort-order #'which-key-key-order-alpha)
  (which-key-mode 1))

;; --- PATH: ~/.local/bin (LSPs, Node, Biome) e MacPorts -------------------------
;; A ordem importa: ~/.local/bin fica na frente, então vence cópias antigas.
(dolist (dir (delq nil (list (and (eq system-type 'darwin) "/opt/local/bin")
                             (expand-file-name "~/.local/bin"))))
  (add-to-list 'exec-path dir)
  (unless (member dir (split-string (or (getenv "PATH") "") ":"))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))))

;; No macOS o Emacs gráfico não herda o PATH do shell.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :demand t
  :config
  ;; O PATH vem do .zshrc (nvm, MacPorts...), então o shell precisa ser interativo,
  ;; o que leva ~1 s. Sobe o limite para o Emacs não avisar a cada inicialização.
  (setq exec-path-from-shell-warn-duration-millis 3000)
  (exec-path-from-shell-initialize))

;; --- macOS (equivalente ao módulo :os macos do Doom) --------------------------
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'super   ns-command-modifier 'super     ; Command = super
        mac-option-modifier 'meta     ns-option-modifier 'meta       ; Option  = meta
        mac-right-option-modifier 'none ns-right-option-modifier 'none
        ns-use-proxy-icon nil
        ns-pop-up-frames nil
        delete-by-moving-to-trash t
        trash-directory "~/.Trash")
  (global-set-key (kbd "s-c") #'kill-ring-save)
  (global-set-key (kbd "s-v") #'yank)
  (global-set-key (kbd "s-x") #'kill-region)
  (global-set-key (kbd "s-a") #'mark-whole-buffer)
  (global-set-key (kbd "s-s") #'save-buffer)
  (global-set-key (kbd "s-q") #'save-buffers-kill-emacs)
  (global-set-key (kbd "s-w") #'delete-window)
  (global-set-key (kbd "s-n") #'make-frame)
  (global-set-key (kbd "s-k") #'kill-current-buffer)
  (global-set-key (kbd "s-`") #'other-frame)
  (global-set-key (kbd "s-+") #'text-scale-increase)
  (global-set-key (kbd "s-=") #'text-scale-increase)
  (global-set-key (kbd "s--") #'text-scale-decrease)
  (global-set-key (kbd "s-0") (lambda () (interactive) (text-scale-set 0)))
  (global-set-key (kbd "s-f") #'consult-line))

(provide 'init-core)
