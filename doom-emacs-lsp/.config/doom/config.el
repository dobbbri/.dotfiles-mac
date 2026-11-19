;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Teclas modificadoras do macOS: já vêm do módulo `:os macos' do init.el
;; (Command = super, Option = meta); não é preciso repetir aqui.

;; 1. PATH: MacPorts e ~/.local/bin (LSPs e Biome instalados pelo install.sh)
;; O `doom sync --env' já captura o PATH do shell; isto garante o GUI mesmo assim.
;; A ordem importa: ~/.local/bin fica na frente, então vence cópias antigas.
(dolist (dir (list "/opt/local/bin" (expand-file-name "~/.local/bin")))
  (add-to-list 'exec-path dir)
  (unless (member dir (split-string (or (getenv "PATH") "") ":"))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))))

;; 2. Tema: Catppuccin (sabores: 'mocha, 'macchiato, 'frappe, 'latte)
(setq catppuccin-flavor 'mocha
      doom-theme 'catppuccin)

;; 3. Interface
(setq display-line-numbers-type 'relative)   ; use t para números absolutos

;; Fonte (exemplo; descomente e ajuste. A Symbols Nerd Font cobre os ícones):
;; (setq doom-font (font-spec :family "JetBrains Mono" :size 14))

;; Onde ficam seus projetos, para o `SPC p p' achá-los sozinho (exemplo):
;; (setq projectile-project-search-path '("~/projects/"))

;; 4. Módulos (cada um num arquivo ao lado deste)
(load! "+treesit")   ; tree-sitter e checagem das gramáticas
(load! "+lsp")       ; lsp-mode, Astro e Tailwind
(load! "+biome")     ; formatação, lint e diagnóstico do Biome
(load! "+org")       ; Org-mode
