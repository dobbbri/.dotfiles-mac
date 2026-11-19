;;; +biome.el -*- lexical-binding: t; -*-

;; BiomeJS: formatação, lint e code actions
;; O Biome lê o biome.json do projeto (indentação, aspas, regras de lint) e usa
;; o binário de node_modules/.bin quando existe; senão, o global.
;; Formatação ao salvar: Apheleia (módulo `format +onsave').
;; Lint, diagnósticos e code actions: lsp-biome (cliente do lsp-mode que roda
;; `biome lsp-proxy' como add-on, junto dos outros servidores).

(defconst my/biome-modos
  '(astro-ts-mode js-mode js-ts-mode typescript-mode typescript-ts-mode
    tsx-ts-mode json-mode json-ts-mode css-mode css-ts-mode)
  "Major modes cujos arquivos são formatados pelo Biome.")

(defconst my/biome-modos-html
  '(html-mode html-ts-mode mhtml-mode mhtml-ts-mode web-mode)
  "Modes de HTML puro: o Biome só formata se o projeto ligar o suporte a HTML.")

(defconst my/biome-versoes-com-problema '("2.5.14" "2.6.0" "2.6.1")
  "Versões testadas que desalinham JSX dentro de expressões {...} em .astro.")

;;;; Leitura do biome.json (parseado, com cache por data de modificação)

(defun my/biome-config-file ()
  "Caminho do biome.json (ou biome.jsonc) mais próximo do arquivo atual."
  (and buffer-file-name
       (or (when-let* ((dir (locate-dominating-file buffer-file-name "biome.json")))
             (expand-file-name "biome.json" dir))
           (when-let* ((dir (locate-dominating-file buffer-file-name "biome.jsonc")))
             (expand-file-name "biome.jsonc" dir)))))

(defun my/biome--sem-comentarios (texto)
  "Remove comentários // e /* */ de TEXTO (o Biome aceita ambos no biome.json)."
  (let ((i 0) (n (length texto)) (em-string nil) (saida nil))
    (while (< i n)
      (let ((c (aref texto i))
            (prox (and (< (1+ i) n) (aref texto (1+ i)))))
        (cond
         (em-string
          (push c saida)
          (cond ((and (eq c ?\\) prox)
                 (push prox saida)
                 (setq i (1+ i)))
                ((eq c ?\") (setq em-string nil))))
         ((eq c ?\") (setq em-string t) (push c saida))
         ((and (eq c ?/) (eq prox ?/))
          (while (and (< i n) (not (eq (aref texto i) ?\n)))
            (setq i (1+ i)))
          (setq i (1- i)))
         ((and (eq c ?/) (eq prox ?*))
          (setq i (+ i 2))
          (while (and (< (1+ i) n)
                      (not (and (eq (aref texto i) ?*)
                                (eq (aref texto (1+ i)) ?/))))
            (setq i (1+ i)))
          (setq i (1+ i)))
         (t (push c saida))))
      (setq i (1+ i)))
    (apply #'string (nreverse saida))))

(defvar my/biome--cache (make-hash-table :test #'equal)
  "Arquivo -> (DATA-DE-MODIFICACAO . DADOS) do biome.json já lido.")

(defun my/biome--dados (file)
  "Conteúdo de FILE como alist, ou nil se ilegível ou inválido."
  (let* ((mtime (file-attribute-modification-time (file-attributes file)))
         (hit (gethash file my/biome--cache)))
    (if (and hit (equal (car hit) mtime))
        (cdr hit)
      (let ((dados (condition-case nil
                       (with-temp-buffer
                         (insert-file-contents file)
                         (json-parse-string
                          (my/biome--sem-comentarios (buffer-string))
                          :object-type 'alist :null-object nil :false-object nil))
                     (error nil))))
        (puthash file (cons mtime dados) my/biome--cache)
        dados))))

(defun my/biome--valor (file chaves &optional profundidade)
  "Valor de CHAVES (lista de símbolos) em FILE, seguindo `extends' relativos."
  (let* ((dados (my/biome--dados file))
         (valor dados))
    (dolist (chave chaves)
      (setq valor (and (consp valor) (alist-get chave valor))))
    (or valor
        (let ((nivel (or profundidade 0))
              (ext (alist-get 'extends dados)))
          (when (< nivel 3)
            (when (vectorp ext) (setq ext (append ext nil)))
            (when (stringp ext) (setq ext (list ext)))
            (seq-some
             (lambda (e)
               (when (and (stringp e) (string-match-p "\\`\\.\\.?/" e))
                 (let ((f (expand-file-name e (file-name-directory file))))
                   (when (file-readable-p f)
                     (my/biome--valor f chaves (1+ nivel))))))
             ext))))))

(defun my/biome-config-valor (&rest chaves)
  "Valor de CHAVES (símbolos) no biome.json do buffer atual, ou nil."
  (when-let* ((file (my/biome-config-file)))
    (my/biome--valor file chaves)))

(defun my/biome-html-habilitado-p ()
  "Não-nil se o biome.json liga `html.experimentalFullSupportEnabled'.
Sem isso o Biome não formata .html e, em .astro, só formata o frontmatter."
  (eq (my/biome-config-valor 'html 'experimentalFullSupportEnabled) t))

;;;; Quando o Biome deve rodar

(defun my/biome-sem-config-p (&rest _)
  "Não-nil quando o Biome NÃO deve rodar neste buffer.
Evita reformatar com os padrões do Biome projetos sem biome.json e evita erro
ao salvar .html quando o suporte a HTML não está ligado no biome.json."
  (cond ((apply #'derived-mode-p my/biome-modos)
         (not (my/biome-config-file)))
        ((apply #'derived-mode-p my/biome-modos-html)
         (not (and buffer-file-name
                   (string-match-p "\\.html?\\'" buffer-file-name)
                   (my/biome-html-habilitado-p))))))

(after! apheleia
  (setf (alist-get 'biome apheleia-formatters)
        '("apheleia-npx" "biome" "format" "--stdin-file-path" filepath))
  (dolist (mode (append my/biome-modos my/biome-modos-html))
    (setf (alist-get mode apheleia-mode-alist) 'biome))
  ;; O Biome não formata YAML: sem formatador padrão nesses modos.
  (dolist (mode '(yaml-mode yaml-ts-mode))
    (setf (alist-get mode apheleia-mode-alist nil 'remove) nil))
  (add-hook 'apheleia-inhibit-functions #'my/biome-sem-config-p))

;; Indentação do Emacs igual à do Biome: se o biome.json usa tabs, o Emacs
;; indenta com tabs (na largura configurada), em vez de brigar com o
;; formatador a cada save. Com `indentStyle: space' nada muda.
(defun my/biome-indentacao-h ()
  "Usa tabs neste buffer quando o biome.json do projeto pede `indentStyle: tab'."
  (when (equal (my/biome-config-valor 'formatter 'indentStyle) "tab")
    (let ((largura (my/biome-config-valor 'formatter 'indentWidth)))
      (setq-local indent-tabs-mode t
                  tab-width (if (integerp largura) largura 2)))))

(dolist (hook '(astro-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                js-ts-mode-hook css-ts-mode-hook json-ts-mode-hook
                mhtml-ts-mode-hook))
  (add-hook hook #'my/biome-indentacao-h))

;; Só o Biome faz lint de JS/TS: desliga o checker e o cliente de LSP alternativos
;; (sem isso o lsp-mode oferece instalar o servidor deles em todo projeto JS).
(after! flycheck
  (add-to-list 'flycheck-disabled-checkers 'javascript-eslint))
(after! lsp-mode
  (add-to-list 'lsp-disabled-clients 'eslint))

;; lsp-biome: só ativa em projetos com biome.json e usa o Biome do projeto
;; (node_modules/@biomejs/biome) ou, na falta dele, o do PATH.
;; Inclui `.astro' e `.html' nos tipos de arquivo (o padrão do pacote não inclui).
(use-package! lsp-biome
  :after lsp-mode
  :config
  (setq lsp-biome-active-file-types
        (list (rx "." (or "tsx" "jsx" "ts" "js" "mts" "mjs" "cts" "cjs"
                          "json" "jsonc" "css" "astro" "html")
                  eos))))

;;;; Lint do projeto e atalhos

(defun my/biome-lint-projeto ()
  "Roda `biome lint' no projeto e lista os problemas num buffer de compilação."
  (interactive)
  (let ((default-directory (if-let* ((proj (project-current)))
                               (project-root proj)
                             default-directory)))
    (compile "npx --no-install biome lint --colors=off --max-diagnostics=200 .")))

(map! :leader
      :desc "Biome: corrigir tudo"      "c B" #'lsp-biome-fix-all
      :desc "Biome: organizar imports"  "c O" #'lsp-biome-organize-imports
      :desc "Biome: lint do projeto"    "c L" #'my/biome-lint-projeto
      :desc "Biome: diagnóstico"        "c D" #'my/biome-diagnostico)

;;;; Diagnóstico (M-x my/biome-diagnostico, SPC c D)

(defun my/biome-binario ()
  "Biome local do projeto (node_modules/.bin) ou, na falta dele, o do PATH."
  (or (when-let* ((dir (and buffer-file-name
                            (locate-dominating-file
                             buffer-file-name "node_modules/.bin/biome"))))
        (expand-file-name "node_modules/.bin/biome" dir))
      (executable-find "biome")))

(defun my/biome-versao (bin)
  "Versão (x.y.z) do executável BIN, ou nil."
  (when bin
    (condition-case nil
        (with-temp-buffer
          (when (zerop (call-process bin nil t nil "--version"))
            (goto-char (point-min))
            (when (re-search-forward "\\([0-9]+\\.[0-9]+\\.[0-9]+\\)" nil t)
              (match-string 1))))
      (error nil))))

(defun my/biome--versao-do-schema ()
  "Versão citada no `$schema' do biome.json atual, ou nil."
  (let ((schema (my/biome-config-valor '$schema)))
    (and (stringp schema)
         (string-match "/schemas/\\([0-9]+\\.[0-9]+\\.[0-9]+\\)/" schema)
         (match-string 1 schema))))

(defun my/biome-diagnostico-texto ()
  "Texto do diagnóstico do Biome para o buffer atual."
  (let* ((config (my/biome-config-file))
         (bin (my/biome-binario))
         (versao (my/biome-versao bin))
         (schema (my/biome--versao-do-schema))
         (estilo (my/biome-config-valor 'formatter 'indentStyle))
         (largura (my/biome-config-valor 'formatter 'indentWidth))
         (html (my/biome-html-habilitado-p))
         (aplica (or (apply #'derived-mode-p my/biome-modos)
                     (apply #'derived-mode-p my/biome-modos-html)))
         (avisos nil))
    (when (and versao schema (not (equal versao schema)))
      (push (format "A versão em uso (%s) difere do $schema (%s): ajuste a versão ou rode `npx biome migrate --write'."
                    versao schema)
            avisos))
    (when (member versao my/biome-versoes-com-problema)
      (push (format "A versão %s desalinha JSX dentro de expressões {...} em .astro (testado em %s). Atualize para 2.6.2 ou mais nova."
                    versao (mapconcat #'identity my/biome-versoes-com-problema ", "))
            avisos))
    (when (and (derived-mode-p 'astro-ts-mode) config (not html))
      (push "O suporte a HTML está desligado: em .astro só o frontmatter é formatado (veja html.experimentalFullSupportEnabled)."
            avisos))
    (concat
     (format "Arquivo:           %s\n" (or buffer-file-name "(buffer sem arquivo)"))
     (format "Modo:              %s\n" major-mode)
     (format "biome.json:        %s\n" (or config "não encontrado"))
     (format "Biome em uso:      %s\n"
             (if bin (format "%s (%s)" bin (or versao "versão desconhecida"))
               "não encontrado (nem no projeto nem no PATH)"))
     (format "Versão no $schema: %s\n" (or schema "não informada"))
     (format "Indentação:        %s, largura %s\n"
             (or estilo "padrão do Biome") (or largura "padrão"))
     (format "Suporte a HTML:    %s\n" (if html "ligado" "desligado"))
     (format "Neste buffer:      %s\n"
             (cond ((not aplica) "não se aplica a este modo")
                   ((my/biome-sem-config-p) "o Biome é pulado (sem biome.json ou sem HTML ligado)")
                   (t "o Biome formata ao salvar")))
     (if avisos
         (concat "\nAvisos:\n" (mapconcat (lambda (a) (concat "  - " a)) (nreverse avisos) "\n") "\n")
       "\nSem avisos.\n"))))

(defun my/biome-diagnostico ()
  "Mostra qual Biome, qual biome.json e quais opções valem para este buffer."
  (interactive)
  (let ((texto (my/biome-diagnostico-texto)))
    (with-help-window "*Biome diagnóstico*"
      (princ texto))))
