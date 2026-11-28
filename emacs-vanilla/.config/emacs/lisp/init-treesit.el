;;; init-treesit.el -*- lexical-binding: t; -*-

;; Emacs 31 instala as gramáticas tree-sitter sozinho. Precisa de git e de um compilador C
;; (macOS: `xcode-select --install'). Elas ficam em ~/.config/emacs/tree-sitter; as que
;; já existirem em ~/.local/lib/tree-sitter (setup antigo do Doom) também são usadas.
(require 'treesit)
;; (add-to-list 'treesit-extra-load-path (expand-file-name "~/.local/lib/tree-sitter"))

(setq treesit-auto-install-grammar 'always   ; instala sem perguntar quando um modo precisar
      treesit-enabled-modes t                ; usa os *-ts-mode no lugar dos modos clássicos
      treesit-font-lock-level 4)

;; O Astro vem de um pacote de terceiros: informa de onde baixar a gramática. As das
;; linguagens embutidas (TypeScript, CSS, YAML...) o próprio Emacs já sabe onde buscar.
(setq treesit-language-source-alist
      '((astro "https://github.com/virchau13/tree-sitter-astro")
        (bash "https://github.com/tree-sitter/tree-sitter-bash")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

;; --- Instalação antecipada --------------------------------------------------------
;; Sem isto cada gramática só é instalada quando você abre o primeiro arquivo da
;; linguagem. Aqui todas as que a config usa são verificadas de uma vez, 2 s depois da
;; inicialização, e as que faltarem são instaladas (na primeira vez, o Emacs pode ficar
;; ocupado por alguns minutos compilando). O install.sh chama a mesma função em modo batch.
(defconst my/treesit-languages
  '(astro bash css elisp go html javascript json markdown python toml tsx typescript yaml)
  "Gramáticas tree-sitter usadas por esta config.")

(defun my/treesit-install-missing ()
  "Instala as gramáticas de `my/treesit-languages' que ainda não estão disponíveis."
  (interactive)
  (dolist (lang my/treesit-languages)
    (unless (treesit-language-available-p lang)
      (message "tree-sitter: instalando a gramática %s..." lang)
      (condition-case err
          (if (fboundp 'treesit-ensure-installed)
              (treesit-ensure-installed lang)
            (treesit-install-language-grammar lang))
        (error (message "tree-sitter: falhou em %s: %s" lang (error-message-string err))))))
  (message "tree-sitter: verificação das gramáticas concluída."))

(unless noninteractive
  (add-hook 'emacs-startup-hook
            (lambda () (run-with-idle-timer 2 nil #'my/treesit-install-missing))))

;; --- Associações de arquivo -------------------------------------------------------
;; TypeScript e Astro não têm modo clássico, e as demais garantem o comportamento mesmo
;; se o `treesit-enabled-modes' não as cobrir (se cobrir, ficam redundantes e inofensivas).
(add-to-list 'auto-mode-alist '("\\.astro\\'" . astro-ts-mode))
(add-to-list 'auto-mode-alist '("\\.[cm]?ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.[cm]?js\\'" . js-ts-mode))   ; .js .mjs .cjs
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))       ; o js-ts-mode já cobre JSX
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsonc?\\'" . json-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
(dolist (mode '(mhtml-mode html-mode))
  (setf (alist-get mode major-mode-remap-alist) 'html-ts-mode))

(provide 'init-treesit)
