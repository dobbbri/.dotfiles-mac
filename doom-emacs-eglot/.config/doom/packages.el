;; -*- no-byte-compile: t; -*-

;; Tema Catppuccin
(package! catppuccin-theme)

;; Major mode nativo em Tree-sitter para Astro
(package! astro-ts-mode)

;; Linter do BiomeJS integrado ao Flycheck
(package! flycheck-biomejs
  :recipe (:host github :repo "craneduck/flycheck-biomejs"))
