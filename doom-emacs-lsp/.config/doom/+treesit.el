;;; +treesit.el -*- lexical-binding: t; -*-

;; Tree-sitter nativo (Emacs 31.1) + módulo `tree-sitter' do Doom
;; O módulo do Doom já define `treesit-enabled-modes' (t) e o nível de realce
;; (4): não repetir aqui. Uma lista própria de ts-modes desligaria o tree-sitter
;; nos modos que o Doom gerencia (ele compara com os modos "base").
;;
;; As gramáticas são compiladas SÓ pelo build-grammars.sh (chamado também pelo
;; install.sh) e ficam em ~/.local/lib/tree-sitter. O Emacs não instala nada
;; sozinho (`treesit-auto-install-grammar' = never): se faltar uma gramática,
;; rode o script (veja o README).
(defconst my/treesit-dir (expand-file-name "~/.local/lib/tree-sitter")
  "Pasta onde o build-grammars.sh instala as gramáticas.")

(setq treesit-auto-install-grammar 'never)

(defun my/treesit-registrar-dir ()
  "Garante `my/treesit-dir' no `treesit-extra-load-path'."
  (add-to-list 'treesit-extra-load-path my/treesit-dir))

;; Na carga do config e de novo quando o `treesit' (e o módulo do Doom) carregar,
;; para não depender da ordem em que os dois mexem na lista.
(my/treesit-registrar-dir)
(with-eval-after-load 'treesit
  (my/treesit-registrar-dir))

;; Checagem das gramáticas
;; O astro-ts-mode exige astro, css e tsx: se faltar uma, o modo vira só "Astro",
;; sem tree-sitter. Esta checagem roda ao abrir o primeiro arquivo e também sob
;; demanda (M-x my/treesit-checar-gramaticas).
(defconst my/treesit-gramaticas
  '(astro bash css html javascript json yaml typescript tsx)
  "Gramáticas que o build-grammars.sh deve ter compilado.")

(defun my/treesit-gramaticas-faltando ()
  "Gramáticas de `my/treesit-gramaticas' que o Emacs não consegue carregar."
  (seq-remove #'treesit-language-available-p my/treesit-gramaticas))

(defun my/treesit--motivo (lang)
  "Motivo (símbolo, como `not-found') de LANG não carregar, como texto."
  (let ((detalhe (treesit-language-available-p lang t)))
    (if (consp detalhe) (format "%s" (cadr detalhe)) "desconhecido")))

(defun my/treesit-checar-gramaticas (&optional interativo)
  "Avisa se faltar alguma gramática tree-sitter e mostra onde procurar.
Chamada com M-x (INTERATIVO), também confirma quando está tudo certo."
  (interactive "p")
  (let ((faltando (my/treesit-gramaticas-faltando)))
    (cond
     (faltando
      (display-warning
       'tree-sitter
       (format (concat "Gramáticas faltando:\n%s\n\n"
                       "Pasta esperada: %s\n"
                       "  existe: %s | está no treesit-extra-load-path: %s\n"
                       "Compile com: ~/.dotfiles-mac/doom-emacs-lsp/build-grammars.sh %s")
               (mapconcat (lambda (l) (format "  - %s (%s)" l (my/treesit--motivo l)))
                          faltando "\n")
               my/treesit-dir
               (if (file-directory-p my/treesit-dir) "sim" "NÃO")
               (if (member my/treesit-dir treesit-extra-load-path) "sim" "NÃO")
               (mapconcat #'symbol-name faltando " "))
       :warning))
     (interativo
      (message "Tree-sitter: todas as gramáticas estão disponíveis.")))))

(add-hook 'doom-first-file-hook #'my/treesit-checar-gramaticas)
