;;; init.el -*- lexical-binding: t; -*-

(doom!
 :input

 :completion
 (company +childframe)

 :ui
 doom
 doom-dashboard
 hl-todo
 modeline
 nav-flash
 ophints
 (popup +defaults)
 treemacs
 vc-gutter
 vi-tilde-fringe
 window-select

 :editor
 (format +onsave)
 snippets

 :emacs
 dired
 electric
 undo
 vc

 :checkers
 (syntax +flycheck)

 :tools
 (lsp +peek)
 magit

 :lang
 (javascript +lsp)
 (web +lsp)
 (json +lsp)
 (css +lsp)

 :config
 (default +bindings +smartparens)
)
