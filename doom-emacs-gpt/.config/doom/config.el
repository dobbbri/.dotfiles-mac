;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Teclas modificadoras do macOS: já vêm do módulo `:os macos' do init.el
;; (Command = super, Option = meta); não é preciso repetir aqui.

;; 1. PATH: MacPorts e ~/.local/bin (LSPs, Node e Biome instalados pelo install.sh)
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

;; Define a fonte principal e o tamanho 18
(setq doom-font (font-spec :family "Lekton Nerd Font Mono" :size 18 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "Lekton Nerd Font Mono" :size 18))

;; Onde ficam seus projetos, para o `SPC p p' achá-los sozinho (exemplo):
(setq projectile-project-search-path '("~/Codes/"))

;; Dired: pastas primeiro e dotfiles ocultos (`zh' alterna).
;; --group-directories-first exige o ls da GNU (`sudo port install coreutils' -> gls);
;; o ls do macOS não o aceita, por isso só ligamos se o gls existir.
(after! dired
  (when-let* ((gls (executable-find "gls")))
    (setq insert-directory-program gls
          dired-use-ls-dired t
          dired-listing-switches "-alh --group-directories-first"))
  (add-hook 'dired-mode-hook #'dired-omit-mode))
(after! dired-x
  (setq dired-omit-files (concat dired-omit-files "\\|^\\.")))
(map! :after dired :map dired-mode-map :n "zh" #'dired-omit-mode)

;; 4. Módulos (cada um num arquivo ao lado deste)
(load! "+treesit")   ; caminho das gramáticas tree-sitter
(load! "+lsp")       ; lsp-mode, Astro e Tailwind
(load! "+biome")     ; formatação, lint e diagnóstico do Biome
(load! "+org")       ; Org-mode
