;;; init.el -*- lexical-binding: t; -*-

;; Garante que treesit-ready-p exista antes de carregar qualquer autoload de pacote no Emacs 31.1
(require 'treesit)

(doom! :input
       ;;bidi
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       company
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       vc-gutter
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets

       :emacs
       dired
       electric
       ibuffer
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       (eval +overlay)
       lookup
       (lsp +eglot)
       magit
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)

       :lang
       emacs-lisp
       (javascript +lsp +tree-sitter)
       json
       markdown
       (org +pretty)
       sh
       (web +lsp +tree-sitter)
       yaml

       :config
       (default +bindings +smartparens))
