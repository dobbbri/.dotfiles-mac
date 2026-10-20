;;; early-init.el --- Executado antes do init.el e da UI -*- lexical-binding: t; -*-

;; GC desligado durante o boot (o init.el restaura um valor sensato depois).
(setq gc-cons-threshold most-positive-fixnum)

;; Desativa o package.el (usamos straight.el).  Só funciona aqui, não no init.el.
(setq package-enable-at-startup nil)

;; lsp-mode mais rápido com plists (precisa estar definido antes de compilar o lsp-mode;
;; se mudar isso, apague o build do lsp-mode em straight/build e reinicie).
(setenv "LSP_USE_PLISTS" "true")

;; UI sem "flicker" de barras aparecendo e sumindo.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t)

;; Abrir maximizado (só afeta GUI).  Mude para nil para o tamanho padrão.
;; Fica aqui no early-init para o frame já nascer maximizado, sem "pulo" de tamanho.
(defvar ek-start-maximized t
  "Se não-nil, o frame inicial abre maximizado (GUI).")
(when ek-start-maximized
  (push '(fullscreen . maximized) default-frame-alist))

;; Native-comp: sem poluir com avisos.
(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends here
