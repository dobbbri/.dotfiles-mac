;;; init-package.el -*- lexical-binding: t; -*-

(require 'package)

;; NonGNU ELPA (elpa.nongnu.org) fica de fora: o host travava na instalação e
;; todos os pacotes usados aqui também existem no GNU ELPA ou no MELPA.
;; Para reativar, acrescente:  ("nongnu" . "https://elpa.nongnu.org/nongnu/")
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/"))
      package-archive-priorities '(("gnu" . 2) ("melpa" . 1)))

(package-initialize)

;; Na primeira execução baixa o índice dos pacotes; se a rede falhar, segue
;; com o que houver (tente de novo com `M-x package-refresh-contents').
(unless package-archive-contents
  (condition-case err
      (package-refresh-contents)
    (error (message "Não foi possível atualizar os índices: %s" (error-message-string err)))))

;; use-package (embutido) instala o que faltar.
(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t)

(provide 'init-package)
