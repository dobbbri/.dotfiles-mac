;; -*- no-byte-compile: t; -*-

;; Tema Catppuccin
(package! catppuccin-theme)

;; Major mode nativo em Tree-sitter para Astro
(package! astro-ts-mode)

;; Cliente do BiomeJS para o lsp-mode (lint, diagnósticos e code actions)
(package! lsp-biome
  :recipe (:host github :repo "cxa/lsp-biome"))

;; Tailwind CSS para o lsp-mode (roda como add-on, junto dos outros servidores)
(package! lsp-tailwindcss)
