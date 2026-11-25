;;; init.el -*- lexical-binding: t; -*-

;; Config Emacs vanilla baseada no Doom Emacs (Emacs 31).
;; Uso lado a lado com o Doom:  emacs --init-directory ~/.config/emacs-vanilla

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Garante que treesit-ready-p exista antes de qualquer autoload de pacote.
(require 'treesit)

(require 'init-package)    ; package.el, MELPA, use-package
(require 'init-core)       ; padrões sensatos (backups, recentf, scroll, macOS...)
(require 'init-ui)         ; fonte, tema, modeline, números de linha
(require 'init-evil)       ; evil + evil-collection
(require 'init-keys)       ; SPC como leader (general + which-key)
(require 'init-completion) ; vertico, consult, company, ...
(require 'init-dired)      ; dired + dirvish
(require 'init-editor)     ; smartparens, snippets, undo, fold, flycheck, magit, vterm
(require 'init-treesit)    ; caminho das gramáticas tree-sitter
(require 'init-lsp)        ; lsp-mode, Astro e Tailwind
(require 'init-biome)      ; formatação, lint e diagnóstico do Biome
(require 'init-langs)      ; elisp, markdown, yaml, sh...
(require 'init-org)        ; Org-mode

;; Customize fica fora deste arquivo.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file nil 'nomessage))

;;; init.el ends here
