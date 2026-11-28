;;; init-biome.el -*- lexical-binding: t; -*-

;; BiomeJS: formatação (Apheleia), lint e code actions (lsp-biome).
;; Só atua em projetos com biome.json(c) na raiz.

(defconst my/biome-arquivos
  (rx "." (or "js" "jsx" "mjs" "cjs" "ts" "tsx" "mts" "cts"
              "json" "jsonc" "css" "scss" "astro" "html" "htm")
      eos)
  "Arquivos que o Biome formata e analisa.")

(defun my/biome-raiz ()
  "Raiz do projeto do buffer atual, ou nil se não houver projeto."
  (or (and (fboundp 'projectile-project-root)
           (projectile-project-root))
      (when-let* ((proj (project-current)))
        (project-root proj))))

(defun my/biome-sem-config-p (&rest _)
  "Não deixa formatar arquivos do Biome em projetos sem biome.json(c) na raiz."
  (and buffer-file-name
       (string-match-p my/biome-arquivos buffer-file-name)
       (not (when-let* ((raiz (my/biome-raiz)))
              (seq-some (lambda (f) (file-exists-p (expand-file-name f raiz)))
                        '("biome.json" "biome.jsonc"))))))

(use-package apheleia
  :demand t
  :config
  ;; Formatter próprio: o embutido roda `biome check --write', que também
  ;; organiza imports; este só formata.
  (setf (alist-get 'biome apheleia-formatters)
        '("apheleia-npx" "biome" "format" "--stdin-file-path" filepath))
  ;; Por nome de arquivo, vale em qualquer modo (js-ts-mode, typescript-ts-mode...).
  (add-to-list 'apheleia-mode-alist (cons my/biome-arquivos 'biome))
  (dolist (mode '(yaml-mode yaml-ts-mode))
    (setf (alist-get mode apheleia-mode-alist nil 'remove) nil))
  (add-hook 'apheleia-inhibit-functions #'my/biome-sem-config-p)
  (apheleia-global-mode 1))                 ; (format +onsave)

(use-package lsp-biome
  :vc (:url "https://github.com/cxa/lsp-biome" :rev :newest)
  :after lsp-mode
  :config (setq lsp-biome-active-file-types (list my/biome-arquivos)))

(defun my/biome-fix-all ()
  "Aplica todas as correções seguras do Biome via LSP."
  (interactive)
  (lsp-execute-code-action-by-kind "source.fixAll.biome"))

(defun my/biome-organize-imports ()
  "Organiza imports do Biome via LSP."
  (interactive)
  (lsp-execute-code-action-by-kind "source.organizeImports.biome"))

(defun my/biome-lint-projeto ()
  "Roda `biome lint' na raiz do projeto (Biome local primeiro, depois o do PATH)."
  (interactive)
  (let ((default-directory (or (my/biome-raiz) default-directory)))
    (compile "PATH=node_modules/.bin:$PATH biome lint --colors=off --max-diagnostics=200 .")))

(my/leader
  "cB"  '(:ignore t :which-key "biome")
  "cBf" '(my/biome-fix-all :which-key "Corrigir tudo")
  "cBo" '(my/biome-organize-imports :which-key "Organizar imports")
  "cBl" '(my/biome-lint-projeto :which-key "Lint do projeto"))

(provide 'init-biome)
