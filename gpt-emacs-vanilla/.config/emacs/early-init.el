;;; early-init.el -*- lexical-binding: t; -*-

;; Carregado antes da interface gráfica e do package.el.

;; GC sem limite durante a inicialização; o gcmh (init-core.el) assume depois.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; O package.el é inicializado em init.el.
(setq package-enable-at-startup nil)

;; Prefere o .el mais novo ao .elc antigo (evita carregar bytecode desatualizado).
(setq load-prefer-newer t)

;; O custom-file precisa existir ANTES de qualquer instalação de pacote: senão o
;; package.el grava `package-selected-packages' dentro do próprio init.el.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Pequenos ganhos: sem a segunda passada (sem diferenciar maiúsculas) sobre o
;; `auto-mode-alist' e sem compactar o cache de fontes (ícones Nerd Font).
(setq auto-mode-case-fold nil
      inhibit-compacting-font-caches t)

;; Evita redimensionar o frame a cada mudança de fonte/barra.
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;; Interface limpa (no macOS gráfico a menu bar fica: ela é a barra global do sistema).
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
(unless (eq system-type 'darwin)
  (push '(menu-bar-lines . 0) default-frame-alist))
(when (eq system-type 'darwin)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

;; No terminal (emacs -nw) a menu bar ocupa uma linha da tela, mesmo no macOS. O
;; frame inicial do terminal é criado antes do early-init, então o
;; `default-frame-alist' não o alcança: o parâmetro é ajustado direto nele.
(unless initial-window-system
  (push '(menu-bar-lines . 0) default-frame-alist)
  (set-frame-parameter nil 'menu-bar-lines 0))

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil)

;; O Emacs 31 avisa quando um pacote antigo não tem o cookie `lexical-binding'.
;; É só um aviso (o pacote funciona igual); oculta o pop-up e o registro.
(setq warning-suppress-types '((files missing-lexbind-cookie))
      warning-suppress-log-types '((files missing-lexbind-cookie)))

;; Compilação nativa em silêncio.
(setq native-comp-async-report-warnings-errors 'silent)

;; Cache da compilação nativa fica em var/eln-cache/, dentro da pasta da config.
(when (boundp 'native-comp-eln-load-path)
  (startup-redirect-eln-cache
   (expand-file-name "var/eln-cache/" user-emacs-directory)))
