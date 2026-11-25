;;; early-init.el -*- lexical-binding: t; -*-

;; Carregado antes da interface gráfica e do package.el.

;; GC sem limite durante a inicialização; o gcmh (init-core.el) assume depois.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; O package.el é inicializado em init.el.
(setq package-enable-at-startup nil)

;; Evita redimensionar o frame a cada mudança de fonte/barra.
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;; Interface limpa (menu bar só no macOS, onde ela não ocupa espaço no frame).
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
(unless (eq system-type 'darwin)
  (push '(menu-bar-lines . 0) default-frame-alist))
(when (eq system-type 'darwin)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil)

;; O Emacs 31 avisa quando um pacote antigo não tem o cookie `lexical-binding'.
;; É só um aviso (o pacote funciona igual); oculta o pop-up e o registro.
(setq warning-suppress-types '((files missing-lexbind-cookie))
      warning-suppress-log-types '((files missing-lexbind-cookie)))

;; Compilação nativa em silêncio.
(setq native-comp-async-report-warnings-errors 'silent
      native-comp-jit-compilation t)

;; Cache da compilação nativa fica em ~/.config/emacs-vanilla/var/eln-cache/.
(when (boundp 'native-comp-eln-load-path)
  (startup-redirect-eln-cache
   (expand-file-name "var/eln-cache/" user-emacs-directory)))
