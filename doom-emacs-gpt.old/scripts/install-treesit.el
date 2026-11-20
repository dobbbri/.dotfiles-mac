;;; install-treesit.el --- Install required Tree-sitter grammars -*- lexical-binding: t; -*-

(require 'treesit)

(let ((doom-dir (or (getenv "DOOM_EMACS_DIR")
                    (expand-file-name "~/.config/emacs"))))
  (setq user-emacs-directory (file-name-as-directory
                              (expand-file-name doom-dir))))

(unless (treesit-available-p)
  (error "Este Emacs não tem suporte Tree-sitter disponível. Verifique a build do Emacs e o compilador C."))

(setq treesit-language-source-alist
      '((astro "https://github.com/virchau13/tree-sitter-astro")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
             "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "typescript/src")))

(defconst my/required-treesit-grammars
  '(astro css html javascript json tsx typescript))

(dolist (language my/required-treesit-grammars)
  (unless (treesit-ready-p language t)
    (message "Compilando gramática Tree-sitter: %s" language)
    (treesit-install-language-grammar language)))

(message "Tree-sitter: todas as gramáticas necessárias estão disponíveis.")
