;;; early-init.el --- Executado antes do init.el e dos autoloads -*- lexical-binding: t; -*-

;; O Emacs carrega os autoloads dos pacotes ANTES do init.el. Por isso o shim
;; de treesit-ready-p precisa ficar aqui: o autoload do astro-ts-mode (ou de
;; outro pacote) chama a funcao no momento do carregamento.

;; Emacs 31 removeu treesit-ready-p; alguns pacotes ainda chamam.
(unless (fboundp 'treesit-ready-p)
  (defun treesit-ready-p (language &optional _quiet)
    (and (fboundp 'treesit-language-available-p)
         (treesit-language-available-p language))))

;; Segfault em fontset_font via char-displayable-p (Cocoa, Emacs 31 MacPorts).
;; Fixar a reticencia evita a verificacao usada por vertico/marginalia/consult.
(setq truncate-string-ellipsis "…")

(define-advice char-displayable-p (:around (orig char) my/safe)
  "Evita a consulta de fonte que derruba o Emacs; so ASCII e considerado exibivel."
  (if (integerp char)
      (< char 128)
    (funcall orig char)))

;; O init.el chama (package-initialize) explicitamente, depois dos shims acima.
(setq package-enable-at-startup nil)

;; Janela maximizada ao iniciar (aqui, para nao aparecer um redimensionamento).
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq frame-resize-pixelwise t)

;;; early-init.el ends here
