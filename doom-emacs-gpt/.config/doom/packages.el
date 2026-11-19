;;; packages.el -*- lexical-binding: t; -*-

;; Catppuccin Mocha.
(package! catppuccin-theme)

;; Major mode Tree-sitter para arquivos Astro (.astro).
(package! astro-ts-mode)

;; Cliente lsp-mode comunitário que inicia o Biome local do projeto
;; com `biome lsp-proxy` e disponibiliza ações de organizar imports/fix-all.
(package! lsp-biome
  :recipe (:host github :repo "cxa/lsp-biome"))
