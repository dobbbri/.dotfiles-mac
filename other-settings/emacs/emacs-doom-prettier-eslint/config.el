;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; JetBrains Mono, tamanho 13. Os ícones vêm de outra fonte (M-x nerd-icons-install-fonts).
(setq doom-font (font-spec :family "JetBrains Mono" :size 13 :weight 'regular))
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;; --- Tema (doom-themes já vem com o módulo :ui doom) ---------------------

;; Outras opções: doom-one-light, doom-tokyo-night, doom-dracula, doom-nord,
;; doom-nord-light, doom-gruvbox, doom-monokai-pro, doom-vibrant, doom-palenight.
;; Para escolher um tema na hora: SPC h t
(setq doom-theme 'doom-one)

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-visual-bell-config)  ; pisca a modeline no lugar do sino
  (doom-themes-org-config))         ; ajustes de aparência para o Org

(defvar my/theme-escuro 'doom-one "Tema escuro usado por `my/toggle-theme'.")
(defvar my/theme-claro 'doom-one-light "Tema claro usado por `my/toggle-theme'.")

(defun my/toggle-theme ()
  "Alterna entre o tema escuro e o claro."
  (interactive)
  (let ((novo (if (eq doom-theme my/theme-escuro) my/theme-claro my/theme-escuro)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme novo t)
    (setq doom-theme novo)
    (message "Tema: %s" novo)))

(map! :leader :desc "Alternar tema claro/escuro" "t T" #'my/toggle-theme)

;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;; --- Astro + tree-sitter (Emacs 31) ---------------------------------------

;; O Emacs 31 já instala grammars e troca para os modos *-ts-mode sozinho,
;; então o pacote `treesit-auto' deixou de ser necessário.
(after! treesit
  (setq! treesit-auto-install-grammar 'ask
         treesit-enabled-modes '(typescript-ts-mode tsx-ts-mode js-ts-mode
                                 css-ts-mode json-ts-mode yaml-ts-mode))
  ;; Fontes das grammars exigidas pelo astro-ts-mode
  (add-to-list 'treesit-language-source-alist
               '(astro "https://github.com/virchau13/tree-sitter-astro" "master" "src"))
  ;; Fontes de reserva (só entram se o Emacs não trouxer a sua)
  (dolist (src '((css "https://github.com/tree-sitter/tree-sitter-css")
                 (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                             "master" "typescript/src")
                 (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
                      "master" "tsx/src")
                 (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
                             "master" "src")
                 (json "https://github.com/tree-sitter/tree-sitter-json")
                 (yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml")))
    (unless (assq (car src) treesit-language-source-alist)
      (add-to-list 'treesit-language-source-alist src))))

(defun my/treesit-install-grammars ()
  "Instala de uma vez as grammars tree-sitter usadas nesta config.
Requer gcc, g++, make e git. Rode com `M-x my/treesit-install-grammars'."
  (interactive)
  (require 'treesit)
  (dolist (lang '(astro css typescript tsx javascript json yaml))
    (unless (treesit-language-available-p lang)
      (message "Instalando grammar: %s" lang)
      (treesit-install-language-grammar lang))))

(use-package! astro-ts-mode
  :mode "\\.astro\\'")

;; Requer o módulo (format +onsave) no init.el e o prettier-plugin-astro
;; instalado no projeto (declarado em "plugins" no .prettierrc).
(set-formatter! 'prettier-astro
  '("npx" "prettier" "--parser=astro"
    (apheleia-formatters-indent "--use-tabs" "--tab-width" 'astro-ts-mode-indent-offset))
  :modes '(astro-ts-mode))

;; LSP via Eglot (módulo (lsp +eglot)). Requer: npm i -g @astrojs/language-server
;; O astro-ls exige a opção `typescript.tsdk': usamos o TypeScript do projeto
;; (node_modules/typescript/lib) ou, na falta dele, o instalado globalmente.
(defun my/astro-tsdk ()
  "Devolve o diretório lib do TypeScript para o astro-ls."
  (or (when-let* ((root (locate-dominating-file
                         default-directory "node_modules/typescript/lib/typescript.js")))
        (expand-file-name "node_modules/typescript/lib" root))
      (let ((global (expand-file-name
                     "typescript/lib"
                     (string-trim (shell-command-to-string "npm root -g")))))
        (when (file-exists-p (expand-file-name "typescript.js" global))
          global))
      (user-error "TypeScript não encontrado: rode `npm i -D typescript' no projeto")))

(defun my/eglot-merge-completion ()
  "Junta Eglot, palavras do buffer e arquivos numa única lista do Corfu."
  (setq-local completion-at-point-functions
              (list (cape-capf-super #'eglot-completion-at-point
                                     #'cape-dabbrev
                                     #'cape-file))))

(after! eglot
  ;; Junta no Eldoc a documentação do servidor e as mensagens do Flymake.
  (setq eldoc-documentation-strategy #'eldoc-documentation-compose
        ;; Ignora funções do servidor que poluem a tela ou duplicam o Prettier.
        eglot-ignored-server-capabilities '(:documentHighlightProvider
                                            :inlayHintProvider
                                            :documentOnTypeFormattingProvider))
  ;; O Eglot devolve listas parciais; o buster refaz a busca ao digitar mais.
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  (add-hook 'eglot-managed-mode-hook #'my/eglot-merge-completion)
  (add-to-list 'eglot-server-programs
               `(astro-ts-mode
                 . ,(lambda (&rest _)
                      `("astro-ls" "--stdio"
                        :initializationOptions
                        (:typescript (:tsdk ,(my/astro-tsdk))))))))
;; Liga o Eglot em Astro, TypeScript, JSX/TSX, CSS, JSON e YAML.
(dolist (hook '(astro-ts-mode-local-vars-hook
                typescript-ts-mode-local-vars-hook
                tsx-ts-mode-local-vars-hook
                js-ts-mode-local-vars-hook
                css-ts-mode-local-vars-hook
                json-ts-mode-local-vars-hook
                yaml-ts-mode-local-vars-hook))
  (add-hook hook #'lsp! 'append))

;; MDX
(add-to-list 'auto-mode-alist '("\\.mdx\\'" . markdown-mode))

;; React: .tsx usa o tsx-ts-mode; .jsx e .js usam o js-ts-mode, que já entende JSX.
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.[cm]js\\'" . js-ts-mode))

;; Emmet (o módulo web já traz o pacote): digite `div.caixa>ul>li*3' e expanda.
;; Em JSX, `.caixa' vira className em vez de class.
(add-hook! '(html-ts-mode-hook css-ts-mode-hook tsx-ts-mode-hook
             js-ts-mode-hook astro-ts-mode-hook)
           #'emmet-mode)
(after! emmet-mode
  (setq emmet-expand-jsx-className? t)
  (when (boundp 'emmet-jsx-major-modes)
    (dolist (m '(tsx-ts-mode js-ts-mode))
      (add-to-list 'emmet-jsx-major-modes m))))

;; Documentação do candidato ao lado da lista do Corfu.
(after! corfu-popupinfo
  (setq corfu-popupinfo-delay '(0.5 . 0.2)))

;; ESLint no Flymake, ligado só em projetos que têm configuração do ESLint.
;; Requer `npm i -D eslint' no projeto.
(defun my/maybe-enable-eslint ()
  "Liga o flymake-eslint quando o projeto tem configuração do ESLint."
  (when (and (derived-mode-p 'typescript-ts-mode 'tsx-ts-mode 'js-ts-mode
                             'astro-ts-mode)
             (seq-some (lambda (f) (locate-dominating-file default-directory f))
                       '("eslint.config.js" "eslint.config.mjs"
                         "eslint.config.cjs" "eslint.config.ts"
                         ".eslintrc.js" ".eslintrc.cjs" ".eslintrc.json"
                         ".eslintrc")))
    (flymake-eslint-enable)))

(use-package! flymake-eslint
  :defer t)

(add-hook 'eglot-managed-mode-hook #'my/maybe-enable-eslint)

;; Multicursor para o Evil (a tecla líder do evim é `\').
;; C-n seleciona a palavra, n adiciona a próxima, q pula, Esc sai.
(use-package! evim
  :after evil
  :config
  (evim-setup-global-keys))

;; Pergunta uma vez por projeto se você confia nele (Emacs 30+).
(use-package! trust-manager
  :demand t
  :config (trust-manager-mode 1))

;; Ícone do Astro (nf-dev-astro, U+E735) para arquivos .astro e astro-ts-mode.
;; Se aparecer um quadrado, rode `M-x nerd-icons-install-fonts' de novo.
(after! nerd-icons
  (defun my/nerd-icons-astro (&rest args)
    "Devolve o ícone do Astro como string, aceitando :face em ARGS."
    (let ((face (or (plist-get args :face) '(:foreground "#ff5d01"))))
      (propertize "\ue735"
                  'face (list face (list :family nerd-icons-font-family))
                  'rear-nonsticky t)))
  (add-to-list 'nerd-icons-extension-icon-alist '("astro" my/nerd-icons-astro))
  (add-to-list 'nerd-icons-mode-icon-alist '(astro-ts-mode my/nerd-icons-astro)))
