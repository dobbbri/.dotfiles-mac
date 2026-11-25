;;; init-treesit.el -*- lexical-binding: t; -*-

;; Gramáticas compiladas pelo ./build-grammars.sh ficam em
;; ~/.config/emacs-vanilla/tree-sitter (diretório padrão do Emacs); as que já
;; existirem em ~/.local/lib/tree-sitter (Doom) também são usadas.
;; O Emacs não instala nada sozinho: se faltar uma gramática, rode o script.
(add-to-list 'treesit-extra-load-path (expand-file-name "~/.local/lib/tree-sitter"))
(setq treesit-auto-install-grammar 'never
      treesit-font-lock-level 4)

;; Usa o modo ts só se a gramática existir; senão mantém o modo clássico.
(dolist (r '((js-mode      js-ts-mode   javascript)
             (js-jsx-mode  js-ts-mode   javascript)
             (js-json-mode json-ts-mode json)
             (css-mode     css-ts-mode  css)
             (mhtml-mode   html-ts-mode html)
             (html-mode    html-ts-mode html)
             (sh-mode      bash-ts-mode bash)
             (yaml-mode    yaml-ts-mode yaml)))
  (when (treesit-language-available-p (nth 2 r))
    (setf (alist-get (nth 0 r) major-mode-remap-alist) (nth 1 r))))

;; TypeScript não tem modo clássico embutido: associa direto.
(when (treesit-language-available-p 'typescript)
  (add-to-list 'auto-mode-alist '("\\.[cm]?ts\\'" . typescript-ts-mode)))
(when (treesit-language-available-p 'tsx)
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))
(when (treesit-language-available-p 'javascript)
  (add-to-list 'auto-mode-alist '("\\.[cm]?js\\'" . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode)))
(when (treesit-language-available-p 'json)
  (add-to-list 'auto-mode-alist '("\\.jsonc?\\'" . json-ts-mode)))
(when (treesit-language-available-p 'yaml)
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode)))

;; Fallback quando não há gramática de YAML.
(use-package yaml-mode :mode "\\.ya?ml\\'" :defer t)

(provide 'init-treesit)
