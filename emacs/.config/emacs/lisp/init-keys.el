;;; init-keys.el -*- lexical-binding: t; -*-

;; SPC é o leader (em insert/emacs: M-SPC); SPC m é o local leader.

(use-package general
  :demand t
  :config
  (general-create-definer my/leader
    :states '(normal visual motion insert emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  ;; Local leader: atalhos de um modo específico, no mesmo mapa `override' do leader,
  ;; filtrados por :predicate (ex.: :predicate '(derived-mode-p 'dired-mode)).
  ;; Não dá para usar o mapa do modo, porque o Dired já usa SPC como tecla comum.
  (general-create-definer my/local-leader
    :states '(normal visual motion insert emacs)
    :keymaps 'override
    :prefix "SPC m"
    :global-prefix "M-SPC m")

  (my/leader
    "SPC" '(projectile-find-file :which-key "Arquivo do projeto")
    "."   '(find-file :which-key "Abrir arquivo")
    ","   '(consult-buffer :which-key "Trocar de buffer")
    "/"   '(consult-ripgrep :which-key "Buscar no projeto")
    ":"   '(execute-extended-command :which-key "M-x")
    "X"   '(org-capture :which-key "Org capture")
    "x"   '(scratch-buffer :which-key "Scratch")
    "u"   '(universal-argument :which-key "Prefixo universal")

    ;; arquivos
    "f"  '(:ignore t :which-key "arquivos")
    "ff" '(find-file :which-key "Abrir arquivo")
    "fr" '(consult-recent-file :which-key "Recentes")
    "fs" '(save-buffer :which-key "Salvar")
    "fS" '(write-file :which-key "Salvar como")
    "fP" '(projectile-find-file :which-key "Arquivo do projeto")
    "fR" '(rename-visited-file :which-key "Renomear")

    ;; buffers
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "Trocar de buffer")
    "bk" '(kill-current-buffer :which-key "Fechar buffer")
    "bi" '(ibuffer :which-key "ibuffer")
    "bn" '(next-buffer :which-key "Próximo")
    "bp" '(previous-buffer :which-key "Anterior")
    "br" '(revert-buffer-quick :which-key "Recarregar")
    "bs" '(save-buffer :which-key "Salvar")

    ;; janelas
    "w"  '(:ignore t :which-key "janelas")
    "ww" '(other-window :which-key "Próxima")
    "wv" '(evil-window-vsplit :which-key "Dividir |")
    "ws" '(evil-window-split :which-key "Dividir —")
    "wd" '(evil-window-delete :which-key "Fechar")
    "wo" '(delete-other-windows :which-key "Só esta")
    "wh" '(evil-window-left :which-key "←")
    "wj" '(evil-window-down :which-key "↓")
    "wk" '(evil-window-up :which-key "↑")
    "wl" '(evil-window-right :which-key "→")

    ;; workspaces (tab-bar)
    "TAB"     '(:ignore t :which-key "workspaces")
    "TAB TAB" '(tab-bar-switch-to-tab :which-key "Trocar")
    "TAB n"   '(tab-bar-new-tab :which-key "Nova")
    "TAB d"   '(tab-bar-close-tab :which-key "Fechar")
    "TAB r"   '(tab-bar-rename-tab :which-key "Renomear")
    "TAB ]"   '(tab-bar-switch-to-next-tab :which-key "Próxima")
    "TAB ["   '(tab-bar-switch-to-prev-tab :which-key "Anterior")

    ;; projetos
    "p"  '(:ignore t :which-key "projetos")
    "pp" '(projectile-switch-project :which-key "Trocar de projeto")
    "pf" '(projectile-find-file :which-key "Arquivo")
    "pd" '(projectile-find-dir :which-key "Pasta")
    "pb" '(projectile-switch-to-buffer :which-key "Buffer do projeto")
    "pk" '(projectile-kill-buffers :which-key "Fechar buffers")
    "pa" '(projectile-add-known-project :which-key "Adicionar projeto")
    "pD" '(projectile-discover-projects-in-search-path :which-key "Redescobrir")

    ;; busca
    "s"  '(:ignore t :which-key "busca")
    "ss" '(consult-line :which-key "Na linha/buffer")
    "si" '(consult-imenu :which-key "Imenu")
    "sp" '(consult-ripgrep :which-key "No projeto")
    "sd" '(consult-ripgrep :which-key "Na pasta")

    ;; git
    "g"  '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "Magit")
    "gb" '(magit-blame-addition :which-key "Blame")
    "gl" '(magit-log-current :which-key "Log")
    "gd" '(magit-diff-unstaged :which-key "Diff")

    ;; código
    "c"  '(:ignore t :which-key "código")
    "ca" '(lsp-execute-code-action :which-key "Code action")
    "cr" '(lsp-rename :which-key "Renomear símbolo")
    "cf" '(apheleia-format-buffer :which-key "Formatar")
    "cx" '(flycheck-list-errors :which-key "Erros")
    "cd" '(xref-find-definitions :which-key "Ir à definição")
    "cD" '(xref-find-references :which-key "Referências")
    "cw" '(delete-trailing-whitespace :which-key "Limpar espaços")

    ;; abrir
    "o"  '(:ignore t :which-key "abrir")
    "ot" '(vterm :which-key "Terminal")
    "o-" '(dired-jump :which-key "Dired aqui")
    "op" '(dirvish-side :which-key "Árvore lateral")

    ;; alternar
    "t"  '(:ignore t :which-key "alternar")
    "tl" '(display-line-numbers-mode :which-key "Números de linha")
    "tw" '(visual-line-mode :which-key "Quebra visual")
    "tf" '(flycheck-mode :which-key "Flycheck")
    "th" '(hl-line-mode :which-key "Linha atual")

    ;; ajuda
    "h"  '(:ignore t :which-key "ajuda")
    "hf" '(describe-function :which-key "Função")
    "hv" '(describe-variable :which-key "Variável")
    "hk" '(describe-key :which-key "Tecla")
    "hm" '(describe-mode :which-key "Modo")
    "hb" '(describe-bindings :which-key "Atalhos")
    "hp" '(describe-package :which-key "Pacote")

    ;; sair
    "q"  '(:ignore t :which-key "sessão")
    "qq" '(save-buffers-kill-terminal :which-key "Sair")
    "qr" '(restart-emacs :which-key "Reiniciar")))

(provide 'init-keys)
