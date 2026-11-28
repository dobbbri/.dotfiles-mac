;;; init-treesit.el -*- lexical-binding: t; -*-

;; Precisa de git e de um compilador C (macOS: `xcode-select --install'). As gramáticas
;; ficam em ~/.config/emacs/tree-sitter (padrão do Emacs; o --no-folding do Stow mantém a
;; pasta fora do repositório de dotfiles). A instalação é feita na primeira abertura (ver
;; "Instalação antecipada" abaixo); o Emacs 31 ainda instala sozinho o que faltar quando
;; um modo precisar.
(require 'treesit)

(setq treesit-auto-install-grammar 'always   ; instala sem perguntar quando um modo precisar
      treesit-font-lock-level 4)

;; `setopt' (e não `setq'): no Emacs 31 esta opção tem um setter que registra os
;; remapeamentos dos modos; com `setq' o valor muda, mas os remapeamentos não são feitos.
(setopt treesit-enabled-modes t)             ; usa os *-ts-mode no lugar dos modos clássicos

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
;; Todas as gramáticas que a config usa são verificadas de uma vez, 2 s depois de o Emacs
;; abrir, e as que faltarem são instaladas. Na primeira abertura o Emacs fica ocupado por
;; alguns minutos compilando; nas seguintes não há nada a fazer. Isto também cobre o
;; `astro-ts-mode', de terceiros, que não instala as gramáticas de que depende.
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
