;;; config.el -*- lexical-binding: t; -*-

;; ---------------------------------------------------------------------------
;; Básico / UI
;; ---------------------------------------------------------------------------
(setq user-full-name "Seu Nome"
      user-mail-address "voce@exemplo.com")

(setq doom-theme 'doom-one
      doom-font (font-spec :family "JetBrains Mono" :size 14)
      display-line-numbers-type 'relative
      org-directory "~/org/"
      treesit-font-lock-level 4)           ; highlight máximo do tree-sitter

(setq-default tab-width 2
              indent-tabs-mode nil
              standard-indent 2)

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      css-indent-offset 2
      web-mode-markup-indent-offset 2
      web-mode-css-indent-offset 2
      web-mode-code-indent-offset 2)

;; ---------------------------------------------------------------------------
;; Astro
;; ---------------------------------------------------------------------------
(use-package! astro-ts-mode
  :mode "\\.astro\\'"
  :config
  ;; Instala a gramática do Astro se faltar (M-x astro-ts-mode-ensure)
  (when (and (fboundp 'treesit-available-p) (treesit-available-p))
    (unless (treesit-language-available-p 'astro)
      (message "Gramática astro ausente: rode M-x astro-ts-mode-ensure"))))

;; ---------------------------------------------------------------------------
;; LSP (eglot): TypeScript, Astro, Tailwind, Biome
;; ---------------------------------------------------------------------------
(defun my/ts-tsdk ()
  "Caminho do TypeScript local ao projeto (necessário para o astro-ls)."
  (let ((root (locate-dominating-file default-directory "node_modules/typescript")))
    (if root
        (expand-file-name "node_modules/typescript/lib" root)
      ;; fallback: typescript global
      (let ((tsc (executable-find "tsc")))
        (when tsc
          (expand-file-name "../lib/node_modules/typescript/lib"
                            (file-name-directory (file-truename tsc))))))))

(after! eglot
  ;; Astro
  (add-to-list 'eglot-server-programs
               '(astro-ts-mode
                 . (lambda (&rest _)
                     `("astro-ls" "--stdio"
                       :initializationOptions
                       (:typescript (:tsdk ,(or (my/ts-tsdk) "")))))))

  ;; O eglot só usa UM servidor por buffer. Para TS + Tailwind juntos, usamos
  ;; o `rass' (rassumfrassum), que multiplexa servidores:
  ;;   pip install rassumfrassum   (ou pipx install rassumfrassum)
  ;; Sem o `rass' instalado, o eglot segue com o servidor padrão de TS.
  (when (executable-find "rass")
    (add-to-list 'eglot-server-programs
                 '((tsx-ts-mode typescript-ts-mode js-ts-mode)
                   . ("rass" "--"
                      "typescript-language-server" "--stdio"
                      "--"
                      "tailwindcss-language-server" "--stdio"))))

  ;; Menos ruído no minibuffer/eventos
  (setq eglot-events-buffer-config '(:size 0)
        eglot-autoshutdown t))

;; ---------------------------------------------------------------------------
;; ESLint via flymake (independe do LSP)
;; ---------------------------------------------------------------------------
(defconst my/eslint-config-files
  '("eslint.config.js" "eslint.config.mjs" "eslint.config.cjs" "eslint.config.ts"
    ".eslintrc" ".eslintrc.js" ".eslintrc.cjs" ".eslintrc.json"
    ".eslintrc.yml" ".eslintrc.yaml")
  "Arquivos que indicam que o projeto usa ESLint.")

(defun my/project-uses-eslint-p ()
  (seq-some (lambda (f) (locate-dominating-file default-directory f))
            my/eslint-config-files))

(use-package! flymake-eslint
  :defer t
  :init
  (defun my/maybe-enable-eslint ()
    (when (my/project-uses-eslint-p)
      (flymake-eslint-enable)))
  ;; depois do eglot, para que ambos os backends coexistam
  (add-hook 'eglot-managed-mode-hook #'my/maybe-enable-eslint)
  :config
  (setq flymake-eslint-defer-binary-check t))

(defun my/eslint-fix ()
  "Roda `eslint --fix' no arquivo atual e recarrega o buffer."
  (interactive)
  (unless buffer-file-name (user-error "Buffer sem arquivo"))
  (save-buffer)
  (let ((out (get-buffer-create "*eslint-fix*"))
        (default-directory (or (doom-project-root) default-directory)))
    (with-current-buffer out (erase-buffer))
    (if (zerop (call-process "npx" nil out nil "eslint" "--fix" buffer-file-name))
        (progn (revert-buffer t t t)
               (message "ESLint --fix: ok"))
      (pop-to-buffer out))))

;; ---------------------------------------------------------------------------
;; Formatação: Biome se o projeto tiver biome.json, senão Prettier
;; (Prettier + prettier-plugin-tailwindcss ordena as classes do Tailwind)
;; ---------------------------------------------------------------------------
(defun my/project-uses-biome-p ()
  (or (locate-dominating-file default-directory "biome.json")
      (locate-dominating-file default-directory "biome.jsonc")))

(defun my/choose-formatter ()
  (setq-local apheleia-formatter
              (if (my/project-uses-biome-p) 'biome 'prettier)))

(after! apheleia
  (dolist (hook '(js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                  json-ts-mode-hook css-ts-mode-hook web-mode-hook
                  astro-ts-mode-hook))
    (add-hook hook #'my/choose-formatter 90))
  ;; Prettier para Astro precisa do plugin prettier-plugin-astro no projeto
  (setf (alist-get 'astro-ts-mode apheleia-mode-alist) 'prettier))

;; ---------------------------------------------------------------------------
;; Scripts npm/pnpm/yarn/bun (SPC o n)
;; ---------------------------------------------------------------------------
(defun my/js-package-manager (root)
  (cond ((file-exists-p (expand-file-name "pnpm-lock.yaml" root)) "pnpm")
        ((or (file-exists-p (expand-file-name "bun.lockb" root))
             (file-exists-p (expand-file-name "bun.lock" root))) "bun")
        ((file-exists-p (expand-file-name "yarn.lock" root)) "yarn")
        (t "npm")))

(defun my/npm-run ()
  "Escolhe um script do package.json e roda com o gerenciador do projeto."
  (interactive)
  (let* ((root (or (doom-project-root) (user-error "Fora de um projeto")))
         (pkg (expand-file-name "package.json" root)))
    (unless (file-exists-p pkg)
      (user-error "Sem package.json em %s" root))
    (let* ((json (with-temp-buffer
                   (insert-file-contents pkg)
                   (goto-char (point-min))
                   (json-parse-buffer :object-type 'alist)))
           (scripts (mapcar (lambda (c) (symbol-name (car c)))
                            (alist-get 'scripts json)))
           (script (if scripts
                       (completing-read "Script: " scripts nil t)
                     (user-error "Nenhum script no package.json")))
           (default-directory root))
      (compile (format "%s run %s" (my/js-package-manager root) script) t))))

;; ---------------------------------------------------------------------------
;; Prodigy: dev servers em background (SPC o P)
;; ---------------------------------------------------------------------------
(after! prodigy
  ;; Exemplo: ajuste o :cwd para seus projetos.
  ;; (prodigy-define-service
  ;;   :name "Astro dev"
  ;;   :command "npm"
  ;;   :args '("run" "dev")
  ;;   :cwd "~/projetos/meu-site"
  ;;   :tags '(astro)
  ;;   :stop-signal 'sigkill
  ;;   :kill-process-buffer-on-stop t)
  )

;; ---------------------------------------------------------------------------
;; which-key (já vem ativo no núcleo do Doom; aqui só ajustamos)
;; ---------------------------------------------------------------------------
(after! which-key
  (setq which-key-idle-delay 0.3               ; menu aparece mais rápido
        which-key-idle-secondary-delay 0.05    ; navegação entre sub-menus quase instantânea
        which-key-max-description-length 40
        which-key-sort-order #'which-key-key-order-alpha
        which-key-add-column-padding 2)
  ;; Nomes amigáveis para prefixos usados no seu fluxo web
  (which-key-add-key-based-replacements
    "SPC c" "code"
    "SPC o" "open"
    "SPC p" "project"
    "SPC g" "git"
    "SPC s" "search"))

;; ---------------------------------------------------------------------------
;; Keybindings
;; ---------------------------------------------------------------------------
(map! :leader
      :desc "ESLint --fix"          "c F" #'my/eslint-fix
      :desc "Rodar script npm"      "o n" #'my/npm-run
      :desc "Lista de erros (flymake)" "c x" #'flymake-show-buffer-diagnostics)

;; Atalhos úteis no modo normal (evil)
(map! :n "] e" #'flymake-goto-next-error
      :n "[ e" #'flymake-goto-prev-error)

;; ---------------------------------------------------------------------------
;; Extras
;; ---------------------------------------------------------------------------
;; Reabrir arquivos de config comuns em modos certos
(add-to-list 'auto-mode-alist '("\\.env\\(\\..*\\)?\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.\\(eslint\\|prettier\\)rc\\'" . json-ts-mode))
(add-to-list 'auto-mode-alist '("biome\\.jsonc?\\'" . json-ts-mode))

;; Recarrega buffers quando o formatter/eslint externo altera o arquivo
(global-auto-revert-mode 1)
