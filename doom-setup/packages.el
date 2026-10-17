;; -*- no-byte-compile: t; -*-
;; Rode `doom sync` depois de alterar este arquivo.

;; O autoload do astro-ts-mode chama `treesit-ready-p' ao carregar, e essa funcao
;; esta indefinida no Emacs 31 durante o sync/startup. Sem autoloads gerados;
;; o autoload do modo vem do `use-package! :mode' no config.el.
(package! astro-ts-mode :recipe (:build (:not autoloads)))
(package! lsp-tailwindcss
  :recipe (:host github :repo "merrickluo/lsp-tailwindcss"))
(package! treemacs-nerd-icons)
