# Configuração do Emacs

Emacs vanilla moderno (30+) com **Evil**, **tree-sitter**, **LSP (eglot)**, formatação ao salvar e um stack de completion atual.

**Linguagens:** Astro, Bash, JSON, Lua, TypeScript/TSX, JavaScript, YAML, TOML.

## Instalação

1. Copie `early-init.el` e `init.el` para `~/.emacs.d/`.
2. Instale os binários externos (LSPs, formatadores, `rg`, `fd`):
   ```bash
   bash install-deps.sh            # instala tudo (MacPorts + nvm/npm)
   bash install-deps.sh --check    # só verifica o que está instalado
   ```
3. Abra o Emacs (na primeira vez ele baixa os pacotes).
4. Instale as gramáticas tree-sitter: `M-x my/treesit-install-all`.
5. Reinicie o Emacs. Se os ícones aparecerem como quadrados, rode `M-x nerd-icons-install-fonts` e reinicie de novo.

## Convenções

| Tecla | O que faz |
|---|---|
| `SPC` | Tecla líder (nos modos normal, visual e motion). O `which-key` mostra o menu depois de 0,4 s |
| `,` | Local leader (reservado, ainda sem atalhos) |
| `C-g` | No modo insert, volta ao modo normal; em qualquer lugar, cancela |
| `C-u` | Rola meia página para cima (como no Vim) |
| `j` / `k` | Andam por linhas visuais (úteis com quebra de linha) |

O resto é o Vim de sempre (`h j k l`, `w b e`, `dd`, `yy`, `p`, `u`, `C-r`, `/`, `:w`...).

## Atalhos com leader (`SPC`)

### Rápidos

| Tecla | Ação |
|---|---|
| `SPC SPC` | Abrir arquivo do projeto |
| `SPC ,` | Trocar de buffer |
| `SPC /` | Buscar texto no projeto (ripgrep) |
| `SPC .` | Ações sobre o item atual (embark) |

### Arquivos (`SPC f`)

| Tecla | Ação |
|---|---|
| `SPC f f` | Abrir arquivo |
| `SPC f r` | Arquivos recentes |
| `SPC f s` | Salvar |

### Buffers (`SPC b`)

| Tecla | Ação |
|---|---|
| `SPC b b` | Trocar de buffer |
| `SPC b d` | Fechar o buffer atual |
| `SPC b n` / `SPC b p` | Próximo / anterior |

### Janelas (`SPC w`)

| Tecla | Ação |
|---|---|
| `SPC w v` | Dividir na vertical |
| `SPC w s` | Dividir na horizontal |
| `SPC w d` | Fechar a janela |
| `SPC w w` | Ir para a outra janela |

### Busca (`SPC s`)

| Tecla | Ação |
|---|---|
| `SPC s s` | Buscar linha no buffer atual |
| `SPC s i` | Navegar por símbolos do arquivo (imenu) |
| `SPC s p` | Buscar texto no projeto (ripgrep) |
| `SPC s f` | Buscar arquivo por nome (fd) |

### Projeto (`SPC p`)

| Tecla | Ação |
|---|---|
| `SPC p p` | Trocar de projeto |
| `SPC p f` | Abrir arquivo do projeto |
| `SPC p b` | Buffers do projeto |

### Git (`SPC g`)

| Tecla | Ação |
|---|---|
| `SPC g g` | Status do git (Magit) |
| `SPC g b` | Blame do arquivo |
| `SPC g l` | Log da branch atual |

No Magit: `?` abre o menu com todas as teclas, `TAB` expande/recolhe, `s` / `u` fazem stage / unstage, `q` sai. As marcas de alteração na margem vêm do `diff-hl`.

### Código / LSP (`SPC c`)

| Tecla | Ação |
|---|---|
| `SPC c r` | Renomear símbolo |
| `SPC c a` | Ações de código (quick fixes) |
| `SPC c f` | Formatar o buffer agora |
| `SPC c o` | Organizar imports |
| `SPC c d` | Listar diagnósticos (erros e avisos) |
| `SPC c e` | Iniciar o eglot manualmente |

### Toggle (`SPC t`)

| Tecla | Ação |
|---|---|
| `SPC t t` | Trocar de tema (`doom-one`, gruvbox, catppuccin...) |
| `SPC t l` | Ligar/desligar números de linha |
| `SPC t r` | Ligar/desligar o `rass` (Tailwind junto com `ts_ls`/`astro-ls`) |

### Abrir (`SPC o`)

| Tecla | Ação |
|---|---|
| `SPC o t` | Terminal na raiz do projeto (eat) |
| `SPC o T` | Terminal comum (eat) |

### Ajuda e sair

| Tecla | Ação |
|---|---|
| `SPC h f` | Descrever uma função |
| `SPC h v` | Descrever uma variável |
| `SPC h k` | Descrever uma tecla |
| `SPC h m` | Descrever o modo atual |
| `SPC q q` | Sair do Emacs |

## Navegação de código (modo normal)

| Tecla | Ação |
|---|---|
| `gd` | Ir para a definição |
| `gr` | Ver referências |
| `K` | Mostrar a documentação do símbolo |
| `]d` / `[d` | Próximo / anterior erro (flymake) |

## Edição

| Tecla | Ação |
|---|---|
| `gcc` | Comentar/descomentar a linha |
| `gc{movimento}` | Comentar um trecho (ex.: `gcap` comenta o parágrafo) |
| `gc` (modo visual) | Comentar a seleção |
| `ys{movimento}{char}` | Envolver com um par (ex.: `ysiw"` coloca aspas na palavra) |
| `cs{antigo}{novo}` | Trocar o par (ex.: `cs"'` troca `"` por `'`) |
| `ds{char}` | Remover o par (ex.: `ds"`) |
| `S{char}` (modo visual) | Envolver a seleção com um par |

Os pares `()`, `[]`, `{}` e `""` fecham sozinhos (`electric-pair`).

## Completion

| Tecla | Ação |
|---|---|
| `C-n` / `C-p` | Próximo / anterior candidato (minibuffer e popup) |
| `RET` | Confirmar o candidato |
| `C-g` | Cancelar |
| `C-.` | Ações sobre o candidato ou item sob o cursor (embark) |
| `C-;` | Ação padrão para o item sob o cursor (embark dwim) |

O popup do código aparece sozinho enquanto você digita (com ícones e documentação ao lado). Os candidatos aceitam várias palavras em qualquer ordem (`orderless`): digitar `ts app` acha `app.ts`.

## Formatação

A formatação roda ao salvar (apheleia), sem mover o cursor.

| Linguagem | Formatador |
|---|---|
| JS, TS, TSX, JSON | `prettier` |
| Astro | `prettier` + `prettier-plugin-astro` |
| Bash | `shfmt` |
| Lua | `stylua` |
| TOML | `taplo` |
| YAML | `yamlfmt` |

Para Astro, crie um `.prettierrc` no projeto:

```json
{
  "plugins": ["prettier-plugin-astro"],
  "overrides": [{ "files": "*.astro", "options": { "parser": "astro" } }]
}
```

## Comandos úteis (`M-x`)

| Comando | Para quê |
|---|---|
| `my/treesit-install-all` | Instalar as gramáticas tree-sitter que faltam |
| `my/toggle-rass` | Ligar/desligar o Tailwind via `rass` (também em `SPC t r`) |
| `eglot-reconnect` | Reiniciar a conexão com o LSP |
| `eglot-events-buffer` | Ver a conversa com o servidor LSP (depuração) |
| `nerd-icons-install-fonts` | Baixar a fonte dos ícones |
| `my/tsdk` (via `M-:`) | Ver qual TypeScript o `astro-ls` está usando |

## Problemas comuns

- **`astro-ls` não acha o TypeScript:** o projeto precisa de um `node_modules/typescript/lib` com `typescript.js`. Rode `npm install` (ou `npm i -D typescript@6`) e depois `M-x eglot-reconnect`. Se o do projeto não servir, o Emacs usa o TypeScript global e avisa no `*Messages*`.
- **Binário não encontrado (LSP ou formatador):** rode `bash install-deps.sh --check`, reabra o terminal e reinicie o Emacs (ele lê o `PATH` do seu shell de login).
- **Se você mudar a versão padrão do Node pelo nvm:** rode `bash install-deps.sh` de novo para atualizar o symlink `~/.nvm/current`.
- **Ícones como quadrados:** `M-x nerd-icons-install-fonts` e reinicie o Emacs.
