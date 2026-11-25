;;; init-completion.el -*- lexical-binding: t; -*-

;; --- Minibuffer: vertico + orderless + marginalia + consult + embark -----------
(use-package vertico
  :demand t
  :config
  (setq vertico-cycle t)
  (vertico-mode 1)
  (require 'vertico-directory)
  (require 'vertico-multiform)
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word)
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

  ;; Seletores de arquivo (SPC f f, SPC SPC...): mesma ordem do Dired (por código
  ;; de caractere, `string<'), com pastas primeiro quando a lista as traz. O padrão
  ;; do vertico ordena por histórico e tamanho do nome.
  (defun my/vertico-sort-dirs-first (files)
    (let ((files (sort (copy-sequence files) #'string<)))
      (nconc (seq-filter (lambda (f) (string-suffix-p "/" f)) files)
             (seq-remove (lambda (f) (string-suffix-p "/" f)) files))))

  ;; `file' (find-file) e `project-file' (listas planas do projeto). Tire
  ;; `project-file' se preferir os arquivos usados há pouco no topo.
  (setq vertico-multiform-categories
        '((file         (vertico-sort-function . my/vertico-sort-dirs-first))
          (project-file (vertico-sort-function . my/vertico-sort-dirs-first))))
  (vertico-multiform-mode 1))

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :demand t
  :config (marginalia-mode 1))

(use-package nerd-icons-completion
  :after (marginalia nerd-icons)
  :config (nerd-icons-completion-mode 1))

(use-package consult
  :demand t
  :config
  (setq consult-narrow-key "<"
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)))
(use-package embark-consult :after (embark consult))

;; --- Projetos -----------------------------------------------------------------
(use-package projectile
  :demand t
  :config
  ;; Onde ficam seus projetos, para o `SPC p p' achá-los sozinho:
  (setq projectile-project-search-path '("~/Codes/")
        projectile-known-projects-file (expand-file-name "projectile-projects.eld" my/var-dir)
        projectile-cache-file (expand-file-name "projectile.cache" my/var-dir)
        projectile-switch-project-action #'projectile-find-file)
  (projectile-mode 1)
  (when (file-directory-p (expand-file-name "~/Codes/"))
    (projectile-discover-projects-in-search-path)))

;; --- Autocompletar no buffer (company) ------------------------------------------
(use-package company
  :demand t
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2
        company-tooltip-limit 12
        company-selection-wrap-around t
        company-dabbrev-downcase nil
        company-dabbrev-ignore-case nil
        company-require-match nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  (global-company-mode 1))

(provide 'init-completion)
