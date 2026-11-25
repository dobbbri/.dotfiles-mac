# Emacs vanilla (baseado no seu Doom)

## Instalação
Coloque esta pasta em `~/.config/emacs-vanilla` (ou, com Stow, em
`~/.dotfiles-mac/<pacote>/.config/emacs-vanilla`) e rode, sem mexer no Doom:

    emacs --init-directory ~/.config/emacs-vanilla

Na primeira abertura o Emacs baixa os pacotes (precisa de internet e git).
Para torná-la a config padrão, mova a pasta para `~/.emacs.d` ou `~/.config/emacs`
(esta última hoje é a do Doom).

## Dependências externas (as mesmas do Doom)
- Gramáticas tree-sitter: `./build-grammars.sh` (recomendado; roda fora do Emacs) ou
  `M-x my/treesit-instalar-gramaticas` (grava em
  `~/.config/emacs-vanilla/tree-sitter`; precisa de git e de um compilador C, no macOS
  `xcode-select --install`). Gramáticas já existentes em `~/.local/lib/tree-sitter`
  (build-grammars.sh do Doom) também são encontradas.
- Servidores: astro-ls, @tailwindcss/language-server, typescript-language-server,
  vscode-langservers-extracted, `@biomejs/biome` em `~/.local/bin`
- `rg` (consult-ripgrep), `gls` (coreutils, só macOS), `cmake` + `libtool` (vterm)
- Fonte Lekton Nerd Font Mono

## Mapa Doom → vanilla
| Doom | Aqui |
|---|---|
| company / vertico | company / vertico + orderless + marginalia + consult + embark |
| evil +everywhere | evil + evil-collection + evil-org |
| lsp (lsp-mode) | lsp-mode (Tailwind embutido) + lsp-biome |
| format +onsave | apheleia-global-mode |
| workspaces | tab-bar (`SPC TAB`) |
| vc-gutter, ophints, nav-flash | diff-hl, evil-goggles, pulsar |
| (org +pretty) | org-modern |
| `+treesit` `+lsp` `+biome` `+org` | `init-treesit` `init-lsp` `init-biome` `init-org` |

Ficaram de fora: doom-dashboard, file-templates, lsp-ui e a persistência de workspaces.
