;;; +org.el -*- lexical-binding: t; -*-

;; Os caminhos saem de `org-directory': mude só ele para mover tudo.
(setq org-directory "~/org/")

(defconst my/org-inbox    (expand-file-name "inbox.org" org-directory))
(defconst my/org-diario   (expand-file-name "daily/diario.org" org-directory))
(defconst my/org-projetos (expand-file-name "projetos.org" org-directory))

(setq org-default-notes-file my/org-inbox
      org-agenda-files (list org-directory (file-name-directory my/org-diario))
      org-log-done 'time)

(after! org
  ;; Templates de captura rápida (acionados via SPC X)
  (setq org-capture-templates
        `(("t" "Tarefa Rápida (Inbox)" entry
           (file+headline ,my/org-inbox "Tarefas")
           "* TODO %?\n  Criada em: %U\n  %a")

          ("d" "Diário / Nota de Hoje" entry
           (file+olp+datetree ,my/org-diario)
           "* %<%H:%M> - %?\n")

          ("p" "Ideia de Projeto / Código" entry
           (file+headline ,my/org-projetos "Backlog Dev")
           "* TODO %? :dev:\n  %U\n"))))

;; Atalhos de produtividade (SPC n ...)
(map! :leader
      (:prefix ("n" . "notes/org")
       :desc "Abrir Inbox Org"  "i" (cmd! (find-file my/org-inbox))
       :desc "Abrir Diário Org" "d" (cmd! (find-file my/org-diario))
       :desc "Agenda de Hoje"   "a" #'org-agenda-list
       :desc "Lista de TODOs"   "t" #'org-todo-list))
