;;; early-init.el --- Carregado antes da UI e do package.el -*- lexical-binding: t; -*-

;; Acelera o boot: sem GC durante a inicialização, restaura depois.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024)
                           read-process-output-max (* 1024 1024)))) ; LSP lê mais rápido

;; package.el é inicializado manualmente no init.el
(setq package-enable-at-startup nil)

;; Evita piscar/redimensionar a janela ao desligar elementos de UI
(setq frame-inhibit-implied-resize t)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist) ; abre maximizado
(when (eq system-type 'darwin)
  (push '(ns-transparent-titlebar . t) default-frame-alist)
  (push '(ns-appearance . dark) default-frame-alist))

;; Cache de compilação nativa em var/eln-cache (mantém a raiz do ~/.emacs.d limpa)
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename (expand-file-name "var/eln-cache/" user-emacs-directory))))

;; Avisos de compilação nativa de pacotes de terceiros: silencia
(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends here
