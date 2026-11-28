;;; init-core.el -*- lexical-binding: t; -*-

;; --- Arquivos gerados fora da pasta da config --------------------------------
(defconst my/var-dir (expand-file-name "var/" user-emacs-directory))
(make-directory (expand-file-name "backups/" my/var-dir) t)
(make-directory (expand-file-name "auto-save/" my/var-dir) t)

(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" my/var-dir)))
      auto-save-list-file-prefix (expand-file-name "auto-save/" my/var-dir)
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" my/var-dir) t))
      create-lockfiles nil
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 3
      kept-old-versions 1)

;; --- GC / desempenho ----------------------------------------------------------
(use-package gcmh
  :demand t
  :config (gcmh-mode 1))

(setq read-process-output-max (* 1024 1024)   ; LSP lê saídas grandes
      process-adaptive-read-buffering nil
      bidi-inhibit-bpa t
      fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t)

;; Variáveis por buffer: `setq' no init só valeria para o buffer atual, então o
;; valor padrão precisa ser definido com `setq-default'.
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; --- Comportamento geral ------------------------------------------------------
(setq use-short-answers t
      ring-bell-function #'ignore
      sentence-end-double-space nil
      require-final-newline t
      scroll-conservatively 101
      scroll-margin 2
      scroll-preserve-screen-position t
      auto-revert-verbose nil
      global-auto-revert-non-file-buffers t
      vc-follow-symlinks t
      save-interprogram-paste-before-kill t
      help-window-select t)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              display-line-numbers-width 3
              display-line-numbers-widen t
              cursor-in-non-selected-windows nil)

(global-auto-revert-mode 1)
(delete-selection-mode 1)
(blink-cursor-mode -1)
(show-paren-mode 1)
(column-number-mode 1)
(pixel-scroll-precision-mode 1)

(setq recentf-save-file (expand-file-name "recentf" my/var-dir)
      recentf-max-saved-items 300
      savehist-file (expand-file-name "savehist" my/var-dir)
      save-place-file (expand-file-name "saveplace" my/var-dir)
      history-length 1000
      savehist-additional-variables
      '(register-alist mark-ring global-mark-ring search-ring regexp-search-ring))
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)

;; --- Padrões extras (ideias do minimal-emacs.d) -----------------------------------
(setq
 ;; Minibuffer: permite minibuffers aninhados e mantém o cursor fora do prompt
 ;; (recomendado pelo vertico).
 enable-recursive-minibuffers t
 minibuffer-prompt-properties
 '(read-only t intangible t cursor-intangible t face minibuffer-prompt)
 ;; M-x só lista comandos que servem ao modo atual.
 read-extended-command-predicate #'command-completion-default-include-p
 ;; Buffers com o mesmo nome (index.astro) ganham o diretório: pages/index.astro.
 uniquify-buffer-name-style 'forward
 ;; Limites de undo mais altos: o histórico não é truncado cedo (undo-fu-session).
 undo-limit (* 13 160000)
 undo-strong-limit (* 13 240000)
 undo-outer-limit (* 13 24000000)
 ;; Auto-save: apagar o arquivo #x# ao fechar o buffer evita o aviso "has auto save
 ;; data" de sessões antigas; kill ring sem duplicatas.
 kill-buffer-delete-auto-save-files t
 auto-save-include-big-deletions t
 kill-do-not-save-duplicates t
 ;; Só os sistemas de versão que você usa: arquivos abrem mais rápido.
 vc-handled-backends '(Git SVN Hg RCS)
 vc-git-diff-switches '("--histogram")
 ;; Rolagem e cursor.
 auto-window-vscroll nil
 scroll-error-top-bottom t
 highlight-nonselected-windows nil
 ;; Ediff na mesma janela (no macOS evita abrir um frame separado).
 ediff-window-setup-function 'ediff-setup-windows-plain
 ediff-split-window-function 'split-window-horizontally
 ;; Compilação (`SPC c B l'): não pergunta para salvar, mata a anterior, rola até o erro.
 compilation-ask-about-save nil
 compilation-always-kill t
 compilation-scroll-output 'first-error
 ;; Busca de ajuda e imenu.
 apropos-do-all t
 imenu-auto-rescan t
 imenu-max-item-length 160)

(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

;; Comandos "desativados" que só geram aviso (narrow-to-region, upcase-region...).
(dolist (cmd '(narrow-to-region narrow-to-page upcase-region downcase-region
               list-timers list-threads erase-buffer scroll-left set-goal-column))
  (put cmd 'disabled nil))

(use-package which-key
  :ensure nil
  :demand t
  :config
  (setq which-key-idle-delay 0.4
        which-key-sort-order #'which-key-key-order-alpha)
  (which-key-mode 1))

;; --- PATH: ~/.local/bin (LSPs, Biome) e MacPorts ---------------------------------
;; Garante os dois mesmo se o exec-path-from-shell falhar. ~/.local/bin fica na
;; frente, então vence cópias antigas.
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
  (setq ns-command-modifier 'super          ; Command = super
        ns-option-modifier 'meta            ; Option  = meta
        ns-right-option-modifier 'none      ; Option direito livre para acentos
        ns-use-proxy-icon nil
        ns-pop-up-frames nil
        delete-by-moving-to-trash t)        ; apagar manda para a Lixeira
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

;; --- Clipboard no Emacs de terminal (macOS) -----------------------------------------
;; No `emacs -nw' o Emacs não enxerga a área de transferência do sistema: o que você copia
;; no navegador não chega ao `p', ao `C-y' nem ao `yank'. Aqui ele passa a usar o pbpaste e
;; o pbcopy, então `y' no Emacs copia para o macOS e `p' cola o que veio de fora.
;; (O Cmd+V do terminal continua funcionando por conta própria, como colagem do terminal.)
(when (and (eq system-type 'darwin) (not (display-graphic-p))
           (executable-find "pbcopy") (executable-find "pbpaste"))
  (setq interprogram-cut-function
        (lambda (texto)
          (let ((process-connection-type nil)
                (proc (start-process "pbcopy" nil "pbcopy")))
            (process-send-string proc texto)
            (process-send-eof proc)))
        interprogram-paste-function
        (lambda ()
          (let ((texto (shell-command-to-string "pbpaste")))
            (unless (or (string-empty-p texto) (string= texto (car kill-ring)))
              texto)))))

(provide 'init-core)
