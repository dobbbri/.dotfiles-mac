;;; init-org.el -*- lexical-binding: t; -*-

;; Os caminhos saem de `org-directory': mude só ele para mover tudo.
(setq org-directory "~/org/")

(defconst my/org-inbox    (expand-file-name "inbox.org" org-directory))
(defconst my/org-diario   (expand-file-name "daily/diario.org" org-directory))
(defconst my/org-projetos (expand-file-name "projetos.org" org-directory))
(defconst my/org-arquivos (list my/org-inbox my/org-projetos my/org-diario))

;; Garante que pastas e arquivos existam: o datetree do diário exige a pasta
;; daily/, e um arquivo ausente em `org-agenda-files' faz o Org perguntar a cada
;; abertura da agenda se deve removê-lo da lista.
(dolist (f my/org-arquivos)
  (make-directory (file-name-directory f) t)
  (unless (file-exists-p f)
    (write-region "" nil f nil 'silent)))

(setq org-default-notes-file my/org-inbox
      org-agenda-files my/org-arquivos
      org-log-done 'time)

(use-package org
  :ensure nil
  :hook (org-mode . visual-line-mode)
  :config
  (setq org-startup-indented t
        org-hide-emphasis-markers t
        org-ellipsis " ▾"
        org-return-follows-link t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0)

  ;; Templates de captura rápida (acionados via SPC X)
  (setq org-capture-templates
        `(("t" "Tarefa Rápida (Inbox)" entry
           (file+headline ,my/org-inbox "Tarefas")
           "* TODO %?
  Criada em: %U
  %a")

          ("d" "Diário / Nota de Hoje" entry
           (file+olp+datetree ,my/org-diario)
           "* %<%H:%M> - %?
")

          ("p" "Ideia de Projeto / Código" entry
           (file+headline ,my/org-projetos "Backlog Dev")
           "* TODO %? :dev:
  %U
"))))

;; (org +pretty)
(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))

;; (evil +everywhere) no Org e na Agenda
(use-package evil-org
  :after evil
  :hook (org-mode . evil-org-mode)
  :init
  (with-eval-after-load 'org-agenda
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys)))

;; Atalhos de produtividade (SPC n ...)
(my/leader
  "n"  '(:ignore t :which-key "notas/org")
  "ni" `(,(lambda () (interactive) (find-file my/org-inbox)) :which-key "Abrir Inbox Org")
  "nd" `(,(lambda () (interactive) (find-file my/org-diario)) :which-key "Abrir Diário Org")
  "na" '(org-agenda-list :which-key "Agenda de Hoje")
  "nt" '(org-todo-list :which-key "Lista de TODOs")
  "nc" '(org-capture :which-key "Capturar"))

(provide 'init-org)
