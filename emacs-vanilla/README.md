# Emacs vanilla (baseado no seu Doom)

## Instalação
Coloque esta pasta em `~/.config/emacs-vanilla` (ou, com Stow, em
`~/.dotfiles-mac/<pacote>/.config/emacs-vanilla`) e rode, sem mexer no Doom:

    emacs --init-directory ~/.config/emacs-vanilla

Na primeira abertura o Emacs baixa os pacotes (precisa de internet e git).
Para torná-la a config padrão, mova a pasta para `~/.emacs.d` ou `~/.config/emacs`
(esta última hoje é a do Doom).

## Dependências externas (as mesmas do Doom)
- Gramáticas tree-sitter: `./build-grammars.sh` (grava em
  `~/.config/emacs-vanilla/tree-sitter`; precisa de git e de um compilador C, no macOS
  `xcode-select --install`). Gramáticas já existentes em `~/.local/lib/tree-sitter`
  (build-grammars.sh do Doom) também são encontradas.
- Tailwind: `M-x lsp-install-server RET tailwindcss` (o lsp-mode baixa e gerencia o servidor)
- Servidores: astro-ls, typescript-language-server,
  vscode-langservers-extracted, `@biomejs/biome` em `~/.local/bin`
- `rg` (consult-ripgrep), `gls` (coreutils, só macOS), `cmake` + `libtool` (vterm)
- Fonte Lekton Nerd Font Mono

## Mapa Doom → vanilla
| Doom | Aqui |
|---|---|
| company / vertico | [company](https://github.com/company-mode/company-mode) / [vertico](https://github.com/minad/vertico) + [orderless](https://github.com/oantolin/orderless) + [marginalia](https://github.com/minad/marginalia) + [consult](https://github.com/minad/consult) + [embark](https://github.com/oantolin/embark) |
| evil +everywhere | [evil](https://github.com/emacs-evil/evil) + [evil-collection](https://github.com/emacs-evil/evil-collection) + [evil-org](https://github.com/Somelauw/evil-org-mode) |
| lsp (lsp-mode) | [lsp-mode](https://github.com/emacs-lsp/lsp-mode) ([Tailwind embutido](https://emacs-lsp.github.io/lsp-mode/page/lsp-tailwindcss/)) + [lsp-biome](https://github.com/cxa/lsp-biome) |
| format +onsave | [apheleia](https://github.com/radian-software/apheleia) (`apheleia-global-mode`) |
| workspaces | [tab-bar](https://www.gnu.org/software/emacs/manual/html_node/emacs/Tab-Bars.html) (`SPC TAB`) |
| vc-gutter, ophints, nav-flash | [diff-hl](https://github.com/dgutov/diff-hl), [evil-goggles](https://github.com/edkolev/evil-goggles), [pulsar](https://github.com/protesilaos/pulsar) |
| (org +pretty) | [org-modern](https://github.com/minad/org-modern) |
| (eval +overlay) | [eros](https://github.com/xiongtx/eros) |
| `+treesit` `+lsp` `+biome` `+org` | `init-treesit` `init-lsp` `init-biome` `init-org` |

Ficaram de fora: doom-dashboard, file-templates, lsp-ui e a persistência de workspaces.

`SPC` é o leader (`M-SPC` no modo insert). Os atalhos abaixo valem para o modo normal.

## Guia rápido

### Scratch (`*scratch*`)
[Manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/Lisp-Interaction.html)

- **O que é:** buffer temporário que já abre com o Emacs, em `lisp-interaction-mode` (elisp). Não está ligado a um arquivo: o conteúdo some ao fechar o Emacs, a menos que seja salvo.
- **Para que serve:** anotações e rascunhos rápidos, testar elisp na hora, colar um texto para editar.
- **Uso comum:** espaço de "rabisco": digita, avalia ou copia o que precisa e descarta. Quem configura o Emacs usa para testar trechos antes de colocá-los na config.

| Ação | Atalho |
|---|---|
| Abrir o scratch | `SPC x` |
| Trocar de buffer | `SPC b b` |
| Avaliar a função sob o cursor | `SPC m e f` |
| Avaliar a expressão anterior | `SPC m e e` |
| Avaliar a região selecionada | `SPC m e r` |
| Avaliar o buffer inteiro | `SPC m e b` |
| Avaliar uma expressão avulsa | `M-:` |
| Salvar como arquivo | `SPC f S` |

No modo normal do evil o cursor fica sobre o último caractere, então `SPC m e e` pode deixar de fora o último parêntese. Nesse caso use `SPC m e f` ou selecione com `v` e use `SPC m e r`.

### Messages (`*Messages*`)
[Manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/Echo-Area.html)

- **O que é:** buffer onde o Emacs guarda todas as mensagens que aparecem na linha do rodapé (a *echo area*). Na barra só cabe a mensagem mais recente, e as longas ficam cortadas; no buffer você vê tudo, com o histórico.
- **Para que serve:** ler mensagens longas, ver erros e avisos que passaram rápido, e copiar texto de uma mensagem (como o erro de um pacote).
- **Uso comum:** depois de um erro ou aviso, abre o buffer e vai ao fim para ler o que aconteceu. Na config ele abre em uma janela embaixo (cerca de 35% da altura), pela regra de popups do `init-ui.el`.

| Ação | Atalho |
|---|---|
| Abrir o `*Messages*` já no fim | `C-h e` |
| Abrir pelo seletor de buffers | `SPC b b` e digite `*Messages*` |
| Ir ao fim / ao início | `G` / `gg` |
| Buscar texto | `/texto`, depois `n` para a próxima ocorrência |
| Copiar | selecione com `v` ou `V` e aperte `y` |
| Quebrar as linhas longas | `SPC t w` (liga e desliga o `visual-line-mode`) |
| Fechar | `q` |

Buffer parecido: `*Warnings*`, que guarda os avisos do Emacs (como os de compilação). Abre-se com `SPC b b` e o nome do buffer.

### eros
[Repositório](https://github.com/xiongtx/eros)

- **O que é:** *Evaluation Result OverlayS*. Mostra o resultado de avaliar elisp em um balão ao lado do código, em vez de só na linha de mensagens (onde some logo).
- **Para que serve:** ver o resultado de uma expressão sem tirar os olhos do código.
- **Uso comum:** ativo só em `emacs-lisp-mode` (inclui o *scratch*). Exemplo: digite `(+ 1 2)` e avalie com `SPC m e e`; aparece `=> 3` logo depois. Usa os mesmos atalhos de avaliação do scratch. Para desativar, remova o bloco `eros` de `lisp/init-editor.el`.

### Completar: [company](https://github.com/company-mode/company-mode), [vertico](https://github.com/minad/vertico), [orderless](https://github.com/oantolin/orderless), [marginalia](https://github.com/minad/marginalia), [consult](https://github.com/minad/consult), [embark](https://github.com/oantolin/embark)
- **O que é:** o vertico é a lista vertical de seleção na barra de comandos; o orderless busca por palavras em qualquer ordem; o marginalia adiciona anotações às opções; o consult traz comandos de busca; o embark abre ações sobre o item selecionado; o company é o popup de autocompletar no código.
- **Para que serve:** achar arquivos, buffers, comandos e texto rapidamente, e autocompletar enquanto digita.
- **Uso comum:** digita parte do nome, filtra a lista e confirma com `RET`.
- **Atalhos:** `SPC SPC` arquivo do projeto, `SPC ,` trocar de buffer, `SPC /` buscar no projeto, `SPC s s` buscar no buffer, `SPC f r` recentes, `SPC s i` imenu. Na lista: `C-n` e `C-p` navegam, `C-.` abre as ações do embark. No company: `TAB` aceita, `C-n` e `C-p` escolhem.

### Evil: [evil](https://github.com/emacs-evil/evil), [evil-collection](https://github.com/emacs-evil/evil-collection), [evil-org](https://github.com/Somelauw/evil-org-mode)
- **O que é:** teclas do Vim no Emacs. O evil-collection estende isso a Dired, Magit e Help; o evil-org, ao Org.
- **Para que serve:** editar com comandos modais e navegar sem mouse.
- **Uso comum:** `Esc` ou `jk` para o modo normal, `i` para inserir, `v` para selecionar.
- **Atalhos:** `h j k l` movem, `dd` apaga a linha, `yy` copia, `p` cola, `u` desfaz, `C-r` refaz, `gc` comenta, `ys`/`cs`/`ds` mexem em delimitadores. No Org: `TAB` dobra, `gj`/`gk` navegam entre títulos, `M-h`/`M-l` mudam o nível.

### LSP: [lsp-mode](https://github.com/emacs-lsp/lsp-mode), [Tailwind](https://emacs-lsp.github.io/lsp-mode/page/lsp-tailwindcss/), [lsp-biome](https://github.com/cxa/lsp-biome)
- **O que é:** o cliente que conversa com os servidores de linguagem (astro-ls, Biome, Tailwind).
- **Para que serve:** autocompletar inteligente, ir à definição, renomear, code actions e lint. O Tailwind completa as classes.
- **Uso comum:** abrir um arquivo `.astro` ou `.ts`; o LSP inicia sozinho.
- **Atalhos:** `K` documentação, `SPC c d` definição, `SPC c D` referências, `SPC c a` code action, `SPC c r` renomear, `SPC c x` lista de erros, `SPC c B f` corrigir tudo (Biome), `SPC c B o` organizar imports, `SPC c B l` lint do projeto.

### Formatar ao salvar: [apheleia](https://github.com/radian-software/apheleia)
- **O que é:** formata o buffer em segundo plano ao salvar.
- **Para que serve:** manter o código padronizado, com o Biome nos arquivos que ele cobre.
- **Uso comum:** só salvar; atua apenas em projetos com `biome.json`.
- **Atalhos:** `SPC c f` formata na hora, `SPC f s` salva.

### Workspaces: [tab-bar](https://www.gnu.org/software/emacs/manual/html_node/emacs/Tab-Bars.html)
- **O que é:** abas nativas do Emacs, cada uma com seu conjunto de janelas.
- **Para que serve:** separar projetos ou contextos na mesma janela.
- **Uso comum:** uma aba por projeto.
- **Atalhos:** `SPC TAB n` cria, `SPC TAB TAB` troca, `SPC TAB d` fecha, `SPC TAB r` renomeia, `SPC TAB ]` e `SPC TAB [` avançam e voltam.

### Feedback visual: [diff-hl](https://github.com/dgutov/diff-hl), [evil-goggles](https://github.com/edkolev/evil-goggles), [pulsar](https://github.com/protesilaos/pulsar)
- **O que é:** o diff-hl marca na margem as linhas alteradas pelo git; o evil-goggles destaca por um instante o que foi copiado, colado ou apagado; o pulsar faz a linha piscar depois de um salto (ex.: ir a uma definição).
- **Para que serve:** noção visual do que mudou e de onde o cursor foi parar.
- **Uso comum:** funcionam sozinhos, sem atalhos próprios.
- **Atalhos relacionados:** `SPC g g` Magit, `SPC g d` diff.

### Org bonito: [org-modern](https://github.com/minad/org-modern)
- **O que é:** tema visual para o Org (títulos, listas, tags e tabelas mais limpos).
- **Para que serve:** deixar as notas mais legíveis, sem mudar o conteúdo dos arquivos.
- **Uso comum:** ativa automaticamente em arquivos `.org`.
- **Atalhos:** `SPC X` ou `SPC n c` captura, `SPC n i` inbox, `SPC n d` diário, `SPC n a` agenda, `SPC n t` lista de TODOs.

### Arquivos e pastas: [Dired](https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html) + [Dirvish](https://github.com/alexluigit/dirvish)
- **O que é:** o gerenciador de arquivos do Emacs. O Dired lista uma pasta em um buffer, e o Dirvish acrescenta ícones, tamanho dos arquivos e pastas expansíveis.
- **Para que serve:** navegar, criar, renomear, mover, copiar e apagar arquivos e pastas sem sair do Emacs.
- **Uso comum:** abre a pasta, marca o que quer com `m` (ou usa o item sob o cursor) e aplica a ação.

| Ação | Atalho (modo normal) |
|---|---|
| Abrir o Dired na pasta do arquivo atual | `SPC o -` |
| Abrir uma pasta qualquer | `SPC .` e escolha a pasta |
| Árvore lateral | `SPC o p` |
| Navegar | `j` / `k`, `RET` abre, `-` ou `^` sobe uma pasta, `q` fecha |
| Expandir ou recolher uma pasta | `TAB` |
| **Criar arquivo** | `SPC .`, digite o nome novo e salve com `SPC f s` (ou `M-x dired-create-empty-file`) |
| **Criar pasta** | `+` |
| **Renomear / mover** | `R` (mover para outra pasta é o mesmo comando: digite o destino) |
| Renomear editando a lista | `C-x C-q`, edite os nomes e confirme com `C-c C-c` |
| **Copiar** | `C` |
| **Apagar** | `D` (apaga na hora, com confirmação) ou `d` para marcar e `x` para executar |
| Marcar / desmarcar | `m` / `u`; `U` desmarca tudo; `t` inverte as marcas |
| Copiar o nome do arquivo | `Y` |
| Atualizar a lista | `g r` |

Dicas:
- **Mover ou copiar para outra pasta:** divida a janela com `SPC w v` e abra a pasta de destino no outro painel. O destino já vem sugerido, porque `dired-dwim-target` está ligado.
- **Vários arquivos:** marque com `m` e aplique `R`, `C` ou `D`. Sem marcas, a ação vale para o arquivo sob o cursor.
- **No macOS,** apagar manda o arquivo para a Lixeira.
- **Arquivo aberto no buffer:** `SPC f R` renomeia o arquivo atual e `SPC f S` salva uma cópia com outro nome.

### Módulos próprios (`init-treesit`, `init-lsp`, `init-biome`, `init-org`)
Arquivos da config (não pacotes), equivalentes aos módulos `+treesit`, `+lsp`, `+biome` e `+org` do Doom. Cada assunto fica no seu arquivo em `lisp/`; edite o arquivo do assunto para mudar algo. Não têm atalhos próprios.

## Solução de problemas

### Aviso `Package cl is deprecated`
- **O que é:** só um aviso. Algum pacote instalado carrega a biblioteca antiga `cl` com `(require 'cl)`. Nada quebra, e não há nada para corrigir na config (nenhum arquivo em `lisp/` usa o `cl`).
- **Como achar o pacote culpado** (as aspas no `--include` evitam o erro `no matches found` do zsh):

      grep -rl "(require 'cl)" ~/.config/emacs-vanilla/elpa --include='*.el'

  Alternativa: coloque `(setq debug-on-message "Package cl is deprecated")` no começo do `init.el`, reinicie e veja o backtrace do debugger (e remova a linha depois).
- **Falso positivo:** o `dash.el` aparece no grep, mas só carrega o `cl` em Emacs anterior à versão 24.3, então não causa o aviso.
- **Caso encontrado (smartparens 1.11.0):** essa versão tem `(eval-when-compile (require 'cl))`. Sem os arquivos compilados (`.elc`), o Emacs carrega o `.el` em texto e executa essa linha a cada inicialização. A versão mais nova do MELPA usa só o `cl-lib`.
- **Como resolver:**
  1. `M-x package-refresh-contents`
  2. `M-x package-upgrade RET smartparens`
  3. `M-x package-recompile-all` (recria os `.elc` e acelera a inicialização; espere terminar)
  4. Reinicie o Emacs. O aviso pode aparecer uma única vez durante a recompilação, o que é normal.
- Não vale editar arquivos dentro de `elpa/`: a próxima atualização do pacote desfaz a alteração.
