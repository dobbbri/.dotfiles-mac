;;; init.el -*- lexical-binding: t; -*-

;; Doom Emacs - Setup para desenvolvimento web
;; Stack: Node, JSON, Biome, Shell, Astro, JS/TS, Tailwind, Prettier, ESLint
;;
;; Depois de editar: `doom sync` e reinicie o Emacs (ou SPC h r r).
;; Documentação de um módulo: SPC h d m   |   `doom doctor` para diagnosticar.

(doom! :input
       ;;bidi
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       (corfu +orderless +icons +dabbrev)   ; completion-at-point moderno
       (vertico +icons)                     ; minibuffer rápido

       :ui
       doom                                 ; tema/visual do Doom
       doom-dashboard
       doom-quit
       (emoji +unicode)
       hl-todo                              ; destaca TODO/FIXME/NOTE
       indent-guides
       ligatures                            ; ligaduras (=>, !==, etc.)
       modeline
       nav-flash
       ophints
       (popup +defaults)
       tabs                                 ; barra de abas
       treemacs                             ; árvore de arquivos
       vc-gutter                            ; diff git na margem
       vi-tilde-fringe
       workspaces                           ; workspaces por projeto
       zen                                  ; modo sem distração

       :editor
       (evil +everywhere)                   ; keybindings vim
       file-templates
       fold
       (format +onsave)                     ; apheleia: Prettier/Biome ao salvar
       multiple-cursors
       snippets
       word-wrap

       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       undo
       vc

       :term
       vterm                                ; terminal completo

       :checkers
       (syntax +flymake)                    ; flymake: integra com eglot e flymake-eslint
       ;;(spell +flyspell)
       ;;grammar

       :tools
       debugger                             ; DAP (debug de Node/JS)
       direnv                               ; .envrc / versões de node por projeto
       docker
       editorconfig                         ; respeita .editorconfig
       (eval +overlay)
       (lookup +dictionary +docsets)
       (lsp +eglot)                         ; LSP nativo (eglot)
       (magit +icons)                       ; Git (ícones nos arquivos)
       make
       prodigy                              ; gerenciar processos (dev servers)
       tree-sitter                          ; syntax highlight moderno
       upload

       :os
       (:if (featurep :system 'macos) macos)

       :lang
       data                                 ; csv, etc.
       emacs-lisp                           ; para editar sua config
       (javascript +lsp +tree-sitter)       ; JS/TS/JSX/TSX + Node
       (json +lsp +tree-sitter)
       (markdown +grip)
       (org +pretty)
       rest                                 ; testar APIs HTTP (.http)
       (sh +lsp +tree-sitter)               ; shell script (bash-language-server)
       (web +lsp +tree-sitter)              ; HTML/CSS/SCSS (+ base p/ Astro)
       yaml                                 ; configs, CI, docker-compose

       :config
       (default +bindings +smartparens))
