;;; init-treesit.el -*- lexical-binding: t; -*-

;; Emacs 31: com `treesit-auto-install-grammar' em `always', o Emacs baixa e compila a
;; gramática (precisa de git e de um compilador C; no macOS, `xcode-select --install')
;; na primeira vez que um modo precisar dela, e `treesit-enabled-modes' usa os
;; *-ts-mode no lugar dos modos clássicos. As gramáticas ficam em
;; ~/.config/emacs/tree-sitter. As que já existirem em ~/.local/lib/tree-sitter (setup
;; antigo do Doom) também são usadas, sem baixar de novo.
(require 'treesit)
(add-to-list 'treesit-extra-load-path (expand-file-name "~/.local/lib/tree-sitter"))
(setq treesit-auto-install-grammar 'always
      treesit-enabled-modes t
      treesit-font-lock-level 4)

;; O Astro vem de um pacote de terceiros: informa de onde baixar a gramática.
(add-to-list 'treesit-language-source-alist
             '(astro "https://github.com/virchau13/tree-sitter-astro"))

;; O `astro-ts-mode' verifica se as gramáticas estão prontas antes de ativar o modo
;; (não aciona o `treesit-auto-install-grammar' sozinho). Garante a instalação do
;; Astro e das linguagens embutidas (TSX/TypeScript, CSS, HTML) na primeira carga.
(with-eval-after-load 'astro-ts-mode
  (dolist (lang '(astro typescript tsx css html))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

;; Associações diretas ao ts-mode. TypeScript não tem modo clássico embutido, e as
;; demais garantem o comportamento mesmo se o `treesit-enabled-modes' não as cobrir
;; (se cobrir, ficam redundantes e inofensivas).
(add-to-list 'auto-mode-alist '("\.[cm]?ts\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\.tsx\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\.jsonc?\'" . json-ts-mode))
(add-to-list 'auto-mode-alist '("\.ya?ml\'" . yaml-ts-mode))
(dolist (mode '(mhtml-mode html-mode))
  (setf (alist-get mode major-mode-remap-alist) 'html-ts-mode))

(provide 'init-treesit)
