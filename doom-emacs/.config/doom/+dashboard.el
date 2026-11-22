;;; +dashboard.el -*- lexical-binding: t; -*-

;; Dashboard simples: as pastas abrem no Dirvish (ordenado, pastas primeiro), em vez
;; do seletor de arquivos do minibuffer. O `:action' precisa ser um comando nomeado.

(defmacro my/define-dired-command (name dir)
  "Define o comando NAME, que abre DIR (avaliado a cada uso) no Dired/Dirvish."
  `(defun ,name () (interactive) (dired ,dir)))

(my/define-dired-command my/open-projects-dir my/projects-dir)
(my/define-dired-command my/open-org-dir org-directory)
(my/define-dired-command my/open-config-dir doom-user-dir)

(defun my/dashboard-icon (name &optional faicon)
  "Ícone NAME (octicon; com FAICON, do Font Awesome) no estilo do menu do dashboard."
  (funcall (if faicon #'nerd-icons-faicon #'nerd-icons-octicon)
           name :face '+dashboard-menu-title))

(setq +dashboard-menu-sections
      '(("Arquivos recentes"
         :icon (my/dashboard-icon "nf-fa-file_text" t)
         :action recentf-open-files)
        ("Abrir projeto"
         :icon (my/dashboard-icon "nf-oct-briefcase")
         :action projectile-switch-project)
        ("Pasta de projetos"
         :icon (my/dashboard-icon "nf-oct-briefcase")
         :when (file-directory-p my/projects-dir)
         :action my/open-projects-dir)
        ("Agenda do Org"
         :icon (my/dashboard-icon "nf-oct-calendar")
         :when (fboundp 'org-agenda)
         :action org-agenda)
        ("Pasta do Org"
         :icon (my/dashboard-icon "nf-oct-calendar")
         :when (file-directory-p org-directory)
         :action my/open-org-dir)
        ("Configuração do Doom"
         :icon (my/dashboard-icon "nf-oct-tools")
         :when (file-directory-p doom-user-dir)
         :action my/open-config-dir)))
