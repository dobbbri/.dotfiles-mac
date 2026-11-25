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
;; (setq catppuccin-flavor 'mocha
;;       doom-theme 'catppuccin)
(setq doom-theme 'doom-peacock)

;; 3. Interface
(setq display-line-numbers-type 'relative)   ; use t para números absolutos

;; Define a fonte principal e o tamanho 18
(setq doom-font (font-spec :family "Lekton Nerd Font Mono" :size 18 :weight 'normal)
      doom-variable-pitch-font doom-font)

;; Onde ficam seus projetos, para o `SPC p p' achá-los sozinho:
(setq projectile-project-search-path '("~/Codes/"))

;; Dired, Dirvish (inclusive o TAB) e vertico com a mesma ordem: por nome (código de
;; caractere, como o `ls' no macOS), pastas primeiro, sem `-v'. Exige o gls (coreutils).
;; O Doom já liga o dired-omit-mode; aqui também se ocultam todos os dotfiles
;; (`SPC m h' alterna).
(defconst my/ls-switches "-ahl --group-directories-first")
(after! dired-x
  (setq dired-omit-files (concat dired-omit-files "\\|^\\.")))
(after! dired
  (when (executable-find "gls")
    (setq dired-listing-switches my/ls-switches)))
(when (executable-find "gls")
  (setq dirvish-subtree-listing-switches my/ls-switches))

;; Seletores de arquivo do vertico (SPC f P, SPC f p, SPC SPC, find-file): mesma ordem
;; do Dired (por código de caractere, `string<'), com pastas primeiro quando a lista as
;; traz (find-file). O padrão do vertico ordena por histórico e tamanho do nome.
(defun my/vertico-sort-dirs-first (files)
  (let ((files (sort (copy-sequence files) #'string<)))
    (nconc (seq-filter (lambda (f) (string-suffix-p "/" f)) files)
           (seq-remove (lambda (f) (string-suffix-p "/" f)) files))))

(after! vertico-multiform
  ;; `file' (find-file) e `project-file' (listas planas do projeto: SPC f P, SPC SPC).
  ;; Acrescenta só a ordenação e preserva o que o Doom já definiu na categoria
  ;; (como o destaque de pastas). Tire `project-file' da lista se preferir os
  ;; arquivos usados há pouco no topo.
  (dolist (cat '(file project-file))
    (setf (alist-get cat vertico-multiform-categories)
          (cons '(vertico-sort-function . my/vertico-sort-dirs-first)
                (assq-delete-all 'vertico-sort-function
                                 (alist-get cat vertico-multiform-categories))))))

;; 4. Módulos (cada um num arquivo ao lado deste)
(load! "+treesit")   ; caminho das gramáticas tree-sitter
(load! "+lsp")       ; lsp-mode, Astro e Tailwind
(load! "+biome")     ; formatação, lint e diagnóstico do Biome
(load! "+org")       ; Org-mode
