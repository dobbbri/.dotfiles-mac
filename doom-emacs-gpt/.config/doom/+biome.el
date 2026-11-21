;;; +biome.el -*- lexical-binding: t; -*-

;; BiomeJS: formatação (Apheleia), lint e code actions (lsp-biome)

(defconst my/biome-modos
  '(astro-ts-mode js-mode js-ts-mode typescript-mode typescript-ts-mode
    tsx-ts-mode json-mode json-ts-mode css-mode css-ts-mode))

(defconst my/biome-modos-html
  '(html-mode html-ts-mode mhtml-mode mhtml-ts-mode web-mode))

(defvar my/biome--cache (make-hash-table :test #'equal))

(defun my/biome-config-file ()
  "Retorna o caminho do biome.json(c) mais próximo do buffer atual."
  (when buffer-file-name
    (seq-some (lambda (f)
                (when-let* ((dir (locate-dominating-file buffer-file-name f)))
                  (expand-file-name f dir)))
              '("biome.json" "biome.jsonc"))))

(defun my/biome--sem-jsonc ()
  "Remove comentários e vírgulas finais do buffer atual (JSONC).
Strings são consumidas inteiras primeiro, então `//' dentro de uma URL
(como em \"$schema\") nunca é confundido com comentário."
  (goto-char (point-min))
  (while (re-search-forward
          (concat "\"\\(?:[^\"\\\\]\\|\\\\.\\)*\""   ; string
                  "\\|//.*$"                         ; comentário de linha
                  "\\|/\\*[^z-a]*?\\*/"              ; comentário de bloco
                  "\\|\\(,\\)[ \t\n\r]*[]}]")        ; vírgula final
          nil t)
    (cond ((match-beginning 1) (replace-match "" t t nil 1))
          ((/= (char-after (match-beginning 0)) ?\")
           (replace-match " " t t)))))

(defun my/biome-config-valor (&rest chaves)
  "Busca CHAVES no biome.json(c) atual com cache por data de modificação."
  (when-let* ((file (my/biome-config-file))
              (mtime (file-attribute-modification-time (file-attributes file))))
    (let* ((hit (gethash file my/biome--cache))
           (dados (if (and hit (equal (car hit) mtime))
                      (cdr hit)
                    (cdr (puthash file
                                  (cons mtime (ignore-errors
                                                (with-temp-buffer
                                                  (insert-file-contents file)
                                                  (my/biome--sem-jsonc)
                                                  (goto-char (point-min))
                                                  (json-parse-buffer :object-type 'alist
                                                                     :null-object nil
                                                                     :false-object nil))))
                                  my/biome--cache)))))
      (seq-reduce (lambda (acc k) (and (consp acc) (alist-get k acc))) chaves dados))))

(defun my/biome-html-habilitado-p ()
  (eq (my/biome-config-valor 'html 'experimentalFullSupportEnabled) t))

(defun my/biome-sem-config-p (&rest _)
  "Inibe o Biome quando não há biome.json ou quando HTML não está habilitado."
  (cond ((apply #'derived-mode-p my/biome-modos) (not (my/biome-config-file)))
        ((apply #'derived-mode-p my/biome-modos-html)
         (not (and buffer-file-name
                   (string-match-p "\\.html?\\'" buffer-file-name)
                   (my/biome-html-habilitado-p))))))

(after! apheleia
  (setf (alist-get 'biome apheleia-formatters)
        '("apheleia-npx" "biome" "format" "--stdin-file-path" filepath))
  (dolist (mode (append my/biome-modos my/biome-modos-html))
    (setf (alist-get mode apheleia-mode-alist) 'biome))
  (dolist (mode '(yaml-mode yaml-ts-mode))
    (setf (alist-get mode apheleia-mode-alist nil 'remove) nil))
  (add-hook 'apheleia-inhibit-functions #'my/biome-sem-config-p))

(defun my/biome-indentacao-h ()
  (when (equal (my/biome-config-valor 'formatter 'indentStyle) "tab")
    (let ((w (my/biome-config-valor 'formatter 'indentWidth)))
      (setq-local indent-tabs-mode t tab-width (if (integerp w) w 2)))))

(dolist (hook '(astro-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                js-ts-mode-hook css-ts-mode-hook json-ts-mode-hook mhtml-ts-mode-hook))
  (add-hook hook #'my/biome-indentacao-h))

(after! flycheck (add-to-list 'flycheck-disabled-checkers 'javascript-eslint))
(after! lsp-mode (add-to-list 'lsp-disabled-clients 'eslint))

(use-package! lsp-biome
  :after lsp-mode
  :config
  (setq lsp-biome-active-file-types
        (list (rx "." (or "tsx" "jsx" "ts" "js" "mts" "mjs" "cts" "cjs"
                          "json" "jsonc" "css" "astro" "html")
                  eos))))

(defun my/biome-lint-projeto ()
  (interactive)
  (let ((default-directory (or (when-let* ((p (project-current))) (project-root p))
                               default-directory)))
    (compile "npx --no-install biome lint --colors=off --max-diagnostics=200 .")))

(defun my/biome-diagnostico ()
  (interactive)
  (message "Biome: %s | Config: %s | HTML: %s"
           (or (when-let* ((d (and buffer-file-name
                                   (locate-dominating-file buffer-file-name "node_modules/.bin/biome"))))
                 (expand-file-name "node_modules/.bin/biome" d))
               (executable-find "biome")
               "não achado")
           (or (my/biome-config-file) "nenhum")
           (if (my/biome-html-habilitado-p) "on" "off")))

(map! :leader
      :desc "Biome: corrigir tudo"     "c B" (cmd! (if (fboundp 'lsp-biome-fix-all)
                                                       (call-interactively #'lsp-biome-fix-all)
                                                     (lsp-execute-code-action-by-kind "source.fixAll.biome")))
      :desc "Biome: organizar imports" "c O" (cmd! (if (fboundp 'lsp-biome-organize-imports)
                                                       (call-interactively #'lsp-biome-organize-imports)
                                                     (lsp-organize-imports)))
      :desc "Biome: lint do projeto"   "c L" #'my/biome-lint-projeto
      :desc "Biome: diagnóstico"       "c D" #'my/biome-diagnostico)
