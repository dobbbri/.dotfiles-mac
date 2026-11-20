;;; +treesit.el -*- lexical-binding: t; -*-

;; Gramáticas compiladas pelo build-grammars.sh (veja o README).
;; O Emacs não instala nada sozinho: se faltar uma gramática, rode o script.
(add-to-list 'treesit-extra-load-path (expand-file-name "~/.local/lib/tree-sitter"))
(setq treesit-auto-install-grammar 'never)
