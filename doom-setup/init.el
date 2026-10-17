;;; init.el -*- lexical-binding: t; -*-
;; Rode `doom sync` depois de alterar este arquivo.

(doom! :input

       :completion
       (corfu +icons +orderless)        ; completion moderno, com ícones (nerd-icons-corfu)
       (vertico +icons)                 ; minibuffer com ícones

       :ui
       doom
       dashboard
       hl-todo
       modeline                         ; doom-modeline com nerd-icons
       nav-flash
       ophints
       (popup +defaults)
       treemacs
       vc-gutter
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)                 ; apheleia (prettierd, biome, shfmt) ao salvar
       snippets
       (whitespace +guess +trim)

       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       undo
       vc

       :checkers
       syntax                           ; flycheck (diagnósticos do LSP/Biome)

       :tools
       editorconfig
       (eval +overlay)
       lookup
       (lsp +peek)                      ; lsp-mode
       magit
       tree-sitter

       :lang
       emacs-lisp
       (javascript +lsp +tree-sitter)   ; JS/TS/TSX
       (json +lsp +tree-sitter)
       markdown
       (sh +lsp +tree-sitter)           ; bash-language-server + shellcheck
       (web +lsp +tree-sitter)          ; HTML/CSS/SCSS

       :config
       (default +bindings +smartparens))
