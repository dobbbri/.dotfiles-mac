;;; init-langs.el -*- lexical-binding: t; -*-

;; Tree-sitter, LSP e Biome ficam nos módulos próprios; aqui vão os ajustes de
;; linguagem que sobraram (equivalente aos módulos :lang do Doom).

;; --- emacs-lisp ---------------------------------------------------------------
(setq lisp-indent-offset nil)
(my/local-leader
  :predicate '(derived-mode-p 'emacs-lisp-mode)
  "e"  '(:ignore t :which-key "eval")
  "eb" '(eval-buffer :which-key "Buffer")
  "ee" '(eval-last-sexp :which-key "Última expressão")
  "ef" '(eval-defun :which-key "Função")
  "er" '(eval-region :which-key "Região"))

;; --- markdown -----------------------------------------------------------------
(use-package markdown-mode
  :mode (("\\.md\\'" . gfm-mode) ("\\.markdown\\'" . markdown-mode))
  :config
  (setq markdown-fontify-code-blocks-natively t
        markdown-hide-urls nil
        markdown-asymmetric-header t))

;; --- JS/TS: o indent vem do Biome ao salvar; aqui só o que o modo exibe ---------
(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      css-indent-offset 2
      json-ts-mode-indent-offset 2)

;; --- sh ------------------------------------------------------------------------
(setq sh-basic-offset 2)

(provide 'init-langs)
