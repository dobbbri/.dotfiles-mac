# Doom Emacs Dotfiles — macOS Ventura (Intel 2015 / 8GB RAM) + MacPorts

Configuração modular do **Doom Emacs** rodando sobre **GNU Emacs 31.1**, gerenciada via **GNU Stow** (`~/.dotfiles-mac/doom-emacs`). Otimizada para desenvolvimento web moderno (**Astro, React, TypeScript 6, Tailwind CSS, Node.js, BiomeJS**) e organização pessoal (**Org-mode**).

## 📁 Estrutura do Pacote Stow

```text
~/.dotfiles-mac/doom-emacs/
├── .stow-local-ignore   # Impede o Stow de linkar os scripts e o README em ~/
├── install.sh           # Instalador completo (MacPorts, Node, Stow, Doom)
├── update.sh            # Script de atualização de pacotes e sistema
├── build-grammars.sh    # Compila as gramáticas tree-sitter
├── clean.sh             # Limpeza para reinstalar do zero (Doom, links, gramáticas, npm)
├── README.md            # Documentação
└── .config/
    └── doom/
        ├── config.el    # Base (PATH, tema, fonte, Dired) e carrega os módulos abaixo
        ├── +treesit.el  # Caminho das gramáticas tree-sitter
        ├── +lsp.el      # lsp-mode, Astro (astro-ls) e Tailwind
        ├── +biome.el    # Formatação, lint e atalhos do Biome
        ├── +org.el      # Org-mode (capturas e atalhos)
        ├── init.el      # Módulos ativos do Doom Emacs
        ├── packages.el  # Pacotes externos (Catppuccin, astro-ts-mode, lsp-biome, lsp-tailwindcss)
        └── snippets/    # Snippets do yasnippet (o install.sh cria a pasta)
```

## 🚀 Recursos Configurados

* **Emacs 31.1 + Tree-sitter nativo:** realce de sintaxe e análise estrutural para Astro, TSX, TypeScript, JavaScript, HTML, CSS e JSON.
* **lsp-mode (módulo `lsp` do Doom):** conecta os servidores do **Astro**, **TypeScript 6** e **Tailwind CSS** ao mesmo tempo no mesmo buffer (o Tailwind roda como add-on via `lsp-tailwindcss`, com o servidor `0.16.0` fixado no `+lsp.el`). Ajustes leves para 8 GB de RAM (sem lens e sem breadcrumb, file watchers sem `.astro`, `dist` e `.vercel`). O `astro-ls` usa o TypeScript de `node_modules/typescript` do projeto (o do Astro já traz um). A formatação nunca passa pelo LSP (`+format-with-lsp` desligado): quem formata é sempre o Biome via Apheleia.
* **Linter + formatador BiomeJS:** formatação ao salvar via `apheleia` (usa `biome format`: só formata, não organiza imports) e lint/diagnósticos via `lsp-biome` (cliente do lsp-mode que roda `biome lsp-proxy` junto dos outros servidores). Vale para arquivos `.js`, `.jsx`, `.mjs`, `.cjs`, `.ts`, `.tsx`, `.mts`, `.cts`, `.json`, `.jsonc`, `.css`, `.scss`, `.astro`, `.html` e `.htm`, e **só em projetos com `biome.json` ou `biome.jsonc` na raiz do projeto** (um repositório git); sem ele o Biome não roda. YAML fica sem formatador. Veja a seção sobre HTML abaixo.
* **Dired/Dirvish:** pastas primeiro (padrão do Doom quando o `gls` existe; vem do `coreutils`), `TAB` expande a subpasta no mesmo buffer com a mesma ordem, e todos os dotfiles ficam ocultos. `SPC m h` alterna entre ocultar e mostrar.
* **Tema Catppuccin:** sabor *Mocha* ativo por padrão.
* **Org-mode produtivo:** templates de captura rápida (`SPC X`) e atalhos dedicados (`SPC n`). O `+org.el` cria `~/org/inbox.org`, `~/org/projetos.org` e `~/org/daily/diario.org` se não existirem.

## ✅ Pré-requisitos

* **Xcode Command Line Tools** (`xcode-select --install`): o `install.sh` e o `build-grammars.sh` usam o compilador.
* **MacPorts** instalado ([macports.org/install.php](https://www.macports.org/install.php)).
* Este pacote em `~/.dotfiles-mac/doom-emacs`, com os arquivos de configuração em `.config/doom/`.

O `install.sh` confere os três e para com uma mensagem se algum faltar. Para reinstalar do zero, veja *Limpeza* mais abaixo.

## 🛠️ Instalação

1. Dê permissão de execução aos scripts:
   ```bash
   cd ~/.dotfiles-mac/doom-emacs
   chmod +x install.sh update.sh build-grammars.sh clean.sh
   ```

2. *(Se precisar)* ajuste a versão do Node.js em `NODE_VERSION` no topo do `install.sh` e do `update.sh` (hoje `22`). O Node vem do **nvm** (porta `nvm` do MacPorts): o instalador roda `sudo port install nvm`, carrega `/opt/local/share/nvm/init-nvm.sh`, executa `nvm install 22` e define a versão como padrão.

3. Execute o instalador:
   ```bash
   ./install.sh
   ```
   Antes de instalar, ele confere se existem `init.el`, `config.el`, `packages.el`, `+treesit.el`, `+lsp.el`, `+biome.el` e `+org.el` em `.config/doom/`.

4. *(Opcional)* Adicione o CLI do `doom` ao seu `~/.zshrc`:
   ```bash
   echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

5. **Primeiro uso no Emacs** (duas coisas que o instalador não faz; ele as lembra no final):
   * `M-x lsp-install-server RET tailwindcss`: baixa o servidor do Tailwind (versão fixada no `+lsp.el`). Sem isso o Tailwind não funciona. Confira depois com `M-x lsp-tailwindcss-installed-server-version`.
   * Instale a fonte **Lekton Nerd Font Mono** (a do `config.el`) pelo Catálogo de Fontes (Font Book).

> **🌳 Lembrete: gramáticas tree-sitter.** O Emacs **não** instala gramáticas sozinho (`treesit-auto-install-grammar` está em `never`). Todas (`astro`, `bash`, `css`, `html`, `javascript`, `json`, `yaml`, `typescript` e `tsx`) vêm do `build-grammars.sh`, que o `install.sh` já executa.
>
> Se ocorrer algo parecido com isto, **rode o script de instalação**:
> * um `.astro` abre só como "Astro", sem tree-sitter, e sem realce;
> * aparece "Tree-sitter for … isn't available" ao abrir um arquivo;
> * depois de atualizar o Emacs ou o macOS, as gramáticas deixam de carregar.
>
> ```bash
> cd ~/.dotfiles-mac/doom-emacs
> ./build-grammars.sh            # recompila todas (rápido); ou só uma: ./build-grammars.sh tsx
> ./install.sh                   # alternativa: refaz a instalação completa
> ```
>
> **Se o erro continuar depois de rodar o script**, confira de onde o Emacs procura:
> * no terminal: `ls ~/.local/lib/tree-sitter` deve listar nove arquivos `libtree-sitter-*.dylib` (astro, bash, css, html, javascript, json, typescript, tsx e yaml);
> * no Emacs: `M-: treesit-extra-load-path` deve incluir `~/.local/lib/tree-sitter`;
> * o `build-grammars.sh` também cria links em `~/.config/emacs/.local/cache/tree-sitter`, a pasta que o Emacs sempre consulta no Doom. Os comandos `doom sync`, `doom install` e `doom doctor` rodam **sem** o seu `config.el` (portanto sem o `treesit-extra-load-path`) e só enxergam as gramáticas ali. Se aparecer `⛔ Warning (treesit): Cannot activate tree-sitter, because language grammar for astro failed to load` durante o `doom sync`, é isso: rode `./build-grammars.sh --link-only` (só refaz os links, sem recompilar) e o `doom sync` de novo;
> * reinicie o Emacs por completo (`SPC q r` não recarrega o `treesit-extra-load-path` de uma sessão antiga).
>
> O `build-grammars.sh` lista no fim quais gramáticas estão `ok` ou `FALTA`. Depois reinicie o Emacs e confira com `M-: (mapcar #'treesit-language-available-p '(astro css tsx))` (tudo deve ser `t`).

> **🔧 Correção manual dos links (aviso no `doom sync`).** Se o `⛔ Warning (treesit): … grammar for astro failed to load` aparecer durante o `doom sync`, `doom install` ou `doom doctor`, crie os links na pasta de cache do Doom e sincronize de novo (testado e funcionou):
>
> ```bash
> mkdir -p ~/.config/emacs/.local/cache/tree-sitter
> ln -sf ~/.local/lib/tree-sitter/*.dylib ~/.config/emacs/.local/cache/tree-sitter/
> ~/.config/emacs/bin/doom sync
> ```
>
> É o mesmo que `./build-grammars.sh --link-only` faz, seguido do `doom sync`.

> **📝 Fonte e ícones.** O `config.el` usa a **Lekton Nerd Font Mono**. Se o Emacs avisar que a fonte não foi encontrada, liste o nome exato que ele enxerga: `M-x eval-expression` (Option + x no Mac) e cole
>
> ```elisp
> (seq-filter (lambda (f) (string-match-p "Lekton" f)) (font-family-list))
> ```
>
> Os ícones vêm da *Symbols Nerd Font*, que acompanha as fontes Nerd Font. Se aparecerem quadrados vazios, rode `M-x nerd-icons-install-fonts`.

## ⌨️ Atalhos Principais

| Atalho | Ação |
| :--- | :--- |
| `SPC f f` | Buscar arquivo no projeto |
| `SPC c x` | Listar erros e avisos do Linter (BiomeJS + LSP) |
| `SPC c a` | Code Actions (correções rápidas do LSP/Biome) |
| `SPC c D` | Achar referências (padrão do Doom) |
| `SPC c B f` | Biome: aplicar todas as correções automáticas (`lsp-biome-fix-all`) |
| `SPC c B o` | Biome: organizar imports (`lsp-biome-organize-imports`) |
| `SPC c B l` | Biome: lint do projeto inteiro (buffer de compilação) |
| `SPC m h` | No Dired: mostrar ou ocultar dotfiles |
| `TAB` | No Dired: expandir ou recolher a subpasta (Dirvish) |
| `SPC g g` | Abrir Git (Magit) |
| `SPC o t` | Abrir terminal integrado (vterm) |
| `SPC X` | Captura rápida no Org-mode (`t` Tarefa, `d` Diário, `p` Projeto) |
| `SPC n i` / `d` | Abrir `inbox.org` ou `diario.org` |

## 🧾 Log da instalação

No final, o `install.sh` roda `doom sync --env` e `doom doctor` e grava a saída de ambos (também mostrada na tela) em `~/.local/state/doom-emacs/install-AAAAMMDD-HHMMSS.log`. Se o `doom doctor` apontar problemas, o script avisa em vez de parar. Para ver só o que importa: `grep -n -i 'error\|warn' ~/.local/state/doom-emacs/install-*.log`.

## 🧱 Pacotes do MacPorts

Além do Emacs, o `install.sh` instala `ripgrep`, `fd`, `git`, `stow`, `nvm`, `cmake`, `libtool`, `shfmt`, `shellcheck` e `coreutils`. O `cmake` e o `libtool` servem para compilar o `vterm` (`SPC o t`); o `shfmt` e o `shellcheck`, para formatar e checar shell scripts; o `coreutils` traz o `gls`, que o Dired usa para listar as pastas primeiro (o `ls` do macOS não tem essa opção).

## 📦 Pacotes npm globais em `~/.local`

O `install.sh` instala `typescript@6`, `typescript-language-server`, `@astrojs/language-server`, `@biomejs/biome`, `stylelint` e `js-beautify` em `~/.local` (`npm install -g --prefix ~/.local`), **sem sudo**. Assim eles não dependem do MacPorts nem da versão do Node do nvm e continuam lá quando o Node é atualizado. O `update.sh` atualiza no mesmo lugar. O Emacs já inclui `~/.local/bin` no `exec-path`; para usar os comandos no terminal, o `~/.zshrc` precisa de `export PATH="$HOME/.local/bin:$PATH"` (o instalador avisa se faltar).

O servidor do **Tailwind CSS** não vem do npm: o `lsp-tailwindcss` baixa o dele (veja o *Primeiro uso*, acima). Se você tinha o `@tailwindcss/language-server` instalado globalmente, ele não é mais necessário.

Se você já tinha esses pacotes instalados com `sudo npm install -g` (em `/opt/local`), a cópia de `~/.local/bin` passa na frente. Para limpar as antigas: `./clean.sh --sudo-npm` (veja *Limpeza*).

### Node (nvm) no Emacs e no terminal

* **Emacs:** o app gráfico não carrega o nvm, então o `install.sh` cria links estáveis `~/.local/bin/node`, `npm` e `npx` apontando para a versão ativa do nvm (o `update.sh` os refaz depois de `nvm install 22`). Os servidores LSP usam esse `node`.
* **Terminal:** adicione ao `~/.zshrc` a linha `source /opt/local/share/nvm/init-nvm.sh` para usar `nvm`, `node` e `npm` normalmente.
* Não defina `prefix` no `~/.npmrc`: o nvm não funciona com essa opção. Os pacotes globais usam `--prefix ~/.local` direto na linha de comando.

## 🧰 Biome no projeto

O Biome global (instalado pelo `install.sh`) serve de reserva. Em cada projeto, instale a mesma versão do `$schema` do `biome.json`:

```bash
npm i -D --save-exact @biomejs/biome
```

O `biome.json` (ou `biome.jsonc`) precisa estar na **raiz** do projeto: o Emacs não o procura em pastas acima nem abaixo.

## 🌐 Formatação de HTML

O Biome só formata a marcação HTML (em `.astro` e `.html`) com o suporte a HTML ligado. Sem isso, nos `.astro` ele formata apenas o frontmatter e deixa o `<div>…</div>` como está, e nos `.html` o Biome dá erro (o Apheleia mostra o erro e deixa o buffer como está). Adicione ao `biome.json` do projeto:

```json
"html": {
	"experimentalFullSupportEnabled": true,
	"formatter": { "enabled": true },
	"linter": { "enabled": true }
}
```

Para aplicar o Biome de uma vez em um projeto que ainda não segue o `biome.json` (um commit grande, mas só uma vez): `npx biome format --write src`.

## 🩺 Como conferir se está funcionando

* `M-x lsp-describe-session` num `.astro`: deve listar os servidores do Astro, do Tailwind e do Biome (este só se houver `biome.json` na raiz).
* Algo estranho com um servidor: veja os buffers `*lsp-log*` e `*lsp-install*`.

## 🧹 Limpeza (reinstalar do zero)

Antes de uma instalação limpa, rode o `clean.sh`. Ele remove os links do Stow (inclusive os órfãos, que sobram quando a pasta do pacote já foi apagada), o Doom em `~/.config/emacs` e seus dados, as gramáticas de `~/.local/lib/tree-sitter` e os pacotes npm de `~/.local`. Se a pasta do pacote ainda se chamar `doom-emacs-gpt`, ele a renomeia para `doom-emacs`.

```bash
cd ~/.dotfiles-mac/doom-emacs
./clean.sh -n            # só mostra o que faria (nada é alterado)
./clean.sh               # pergunta antes de apagar; use -y para não perguntar
./clean.sh --sudo-npm    # remove também os pacotes npm antigos de /opt/local (sudo)
./install.sh             # instala do zero
```

Ele **não** toca em `~/org`, no MacPorts, no nvm/Node nem nos arquivos de `~/.dotfiles-mac`. Arquivos próprios dentro de `~/.config/doom` (que não sejam links do Stow) são mantidos, com um aviso.

## 🔗 Stow: migrando do pacote antigo `doom-emacs-gpt`

O `.stow-local-ignore` deste pacote impede o Stow de linkar `install.sh`, `update.sh`, `build-grammars.sh`, `clean.sh` e `README.md` em `~/`. Se faltar `clean.sh` nele, acrescente uma linha igual à dos outros scripts.

Para trocar o nome do pacote sem quebrar os links, desfaça-os **antes** de renomear a pasta (o Stow precisa dela com o nome antigo). Se a pasta já foi apagada ou renomeada, o `./clean.sh` remove os links órfãos. À mão:

```bash
cd ~/.dotfiles-mac
stow -D doom-emacs-gpt 2>/dev/null || true
stow -D doom-emacs-lsp 2>/dev/null || true
# renomeia só se o destino ainda não existir (se já houver uma pasta doom-emacs antiga, tire-a do caminho antes)
[ -d doom-emacs-gpt ] && [ ! -e doom-emacs ] && mv doom-emacs-gpt doom-emacs
for f in install.sh update.sh build-grammars.sh clean.sh README.md; do
  [ -L "$HOME/$f" ] && rm "$HOME/$f"
done
stow -v doom-emacs
```

## 🩹 Erros do npm e do nvm na instalação

* **`npm error code EACCES` em `~/.npm/_cacache`:** um `sudo npm` antigo deixou arquivos de root na pasta de cache. O `install.sh` e o `update.sh` detectam isso e corrigem o dono (pedem a senha do sudo). À mão: `sudo chown -R "$(id -u):$(id -g)" ~/.npm`.
* **`nvm is not compatible with the "PREFIX" environment variable`:** o nvm recusa a variável `PREFIX`. Os scripts usam `NPM_PREFIX`, mas se o seu shell exporta `PREFIX` (por exemplo no `~/.zshrc`), rode `unset PREFIX` ou remova a linha.

## 🩹 Aviso "Unable to find typescript server path for astro-ls"

O `astro-ls` lê o TypeScript de `<raiz do projeto>/node_modules/typescript/lib`. Se o aviso mostrar um caminho de subpasta (por exemplo `…/src/components/Footer/node_modules/typescript/lib`), o lsp-mode registrou uma subpasta como raiz, porque no primeiro arquivo você escolheu a opção `.` ("Import project at current directory"). O `+lsp.el` usa `lsp-auto-guess-root` para achar a raiz pelo Git/projectile. Para apagar a raiz errada que já ficou salva e reiniciar:

* `M-x lsp-workspace-folders-remove` e escolha a subpasta errada;
* `M-x lsp-workspace-restart` (ou feche e reabra o arquivo).

## 🔌 Servidores sob demanda (lsp-mode)

Na primeira vez em CSS, HTML ou JSON o lsp-mode pode oferecer a instalação do servidor correspondente; aceite com `y`. Depois de mudar `init.el` ou `packages.el`, rode `doom sync` e reinicie o Emacs.

## 🔄 Manutenção

Para atualizar o MacPorts, pacotes do Node (mantendo o TypeScript 6), links do Stow e o Doom Emacs de uma só vez:
```bash
./update.sh
```

O `update.sh` **não** atualiza o servidor do Tailwind: quem o gerencia é o lsp-mode, na versão fixada no `+lsp.el` (`lsp-tailwindcss-server-version`). Para trocar de versão, mude esse valor e rode `M-x lsp-update-server` (se o `tailwindcss` não aparecer na lista, apague a pasta `tailwindcss/` dentro de `lsp-server-install-dir` e rode `M-x lsp-install-server` de novo).
