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
      doom-variable-pitch-font doom-font)

;; Onde ficam seus projetos: o `SPC p p' os acha sozinho e o dashboard abre esta pasta.
(defconst my/projects-dir (expand-file-name "~/Codes/"))
(setq projectile-project-search-path (list my/projects-dir))

;; Dired/Dirvish: o Doom já lista pastas primeiro (com o gls) e liga o dired-omit-mode.
;; Aqui só: ocultar todos os dotfiles (`SPC m h' alterna) e fixar a mesma ordem no TAB.
(after! dired-x
  (setq dired-omit-files (concat dired-omit-files "\\|^\\.")))
(when (executable-find "gls")
  (setq dirvish-subtree-listing-switches "-ahl -v --group-directories-first"))

;; Seletores de arquivo do vertico (SPC f P, SPC f p, SPC SPC, find-file): ordem
;; alfabética, com pastas primeiro quando a lista as traz (find-file). O padrão do
;; vertico ordena por histórico e tamanho do nome (o que deixa a lista "bagunçada").
(defun my/vertico-sort-dirs-first (files)
  (let ((files (sort (copy-sequence files)
                     (lambda (a b) (string-collate-lessp a b nil t)))))
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
(load! "+dashboard") ; menu inicial simples (pastas abrem no Dirvish)
