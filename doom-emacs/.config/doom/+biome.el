;;; +biome.el -*- lexical-binding: t; -*-

;; BiomeJS: formatação (Apheleia), lint e code actions (lsp-biome).
;; Só atua em projetos com biome.json(c) na raiz.

(defconst my/biome-arquivos
  (rx "." (or "js" "jsx" "mjs" "cjs" "ts" "tsx" "mts" "cts"
              "json" "jsonc" "css" "scss" "astro" "html" "htm")
      eos)
  "Arquivos que o Biome formata e analisa.")

(defun my/biome-raiz ()
  "Raiz do projeto do buffer atual, ou nil se não houver projeto."
  (when-let* ((proj (project-current)))
    (project-root proj)))

(defun my/biome-sem-config-p (&rest _)
  "Não deixa formatar arquivos do Biome em projetos sem biome.json(c) na raiz."
  (and buffer-file-name
       (string-match-p my/biome-arquivos buffer-file-name)
       (not (when-let* ((raiz (my/biome-raiz)))
              (seq-some (lambda (f) (file-exists-p (expand-file-name f raiz)))
                        '("biome.json" "biome.jsonc"))))))

(after! apheleia
  ;; Formatter próprio: o embutido roda `biome check --write', que também
  ;; organiza imports; este só formata.
  (setf (alist-get 'biome apheleia-formatters)
        '("apheleia-npx" "biome" "format" "--stdin-file-path" filepath))
  ;; Por nome de arquivo, vale em qualquer modo (js-mode, typescript-ts-mode...).
  (add-to-list 'apheleia-mode-alist (cons my/biome-arquivos 'biome))
  (dolist (mode '(yaml-mode yaml-ts-mode))
    (setf (alist-get mode apheleia-mode-alist nil 'remove) nil))
  (add-hook 'apheleia-inhibit-functions #'my/biome-sem-config-p))

(after! flycheck (add-to-list 'flycheck-disabled-checkers 'javascript-eslint))
(after! lsp-mode (add-to-list 'lsp-disabled-clients 'eslint))

(use-package! lsp-biome
  :after lsp-mode
  :config (setq lsp-biome-active-file-types (list my/biome-arquivos)))

(defun my/biome-lint-projeto ()
  "Roda `biome lint' na raiz do projeto (Biome local primeiro, depois o do PATH)."
  (interactive)
  (let ((default-directory (or (my/biome-raiz) default-directory)))
    (compile "PATH=node_modules/.bin:$PATH biome lint --colors=off --max-diagnostics=200 .")))

(map! :leader
      (:prefix ("c B" . "biome")
       :desc "Corrigir tudo"     "f" #'lsp-biome-fix-all
       :desc "Organizar imports" "o" #'lsp-biome-organize-imports
       :desc "Lint do projeto"   "l" #'my/biome-lint-projeto))
