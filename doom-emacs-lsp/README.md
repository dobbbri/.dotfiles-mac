# Doom Emacs Dotfiles — macOS Ventura (Intel 2015 / 8GB RAM) + MacPorts

Configuração modular do **Doom Emacs** rodando sobre **GNU Emacs 31.1**, gerenciada via **GNU Stow** (`~/.dotfiles-mac/doom-emacs-lsp`). Otimizada para desenvolvimento web moderno (**Astro, React, TypeScript 6, Tailwind CSS, Node.js, BiomeJS**) e organização pessoal (**Org-mode**).

## 📁 Estrutura do Pacote Stow

```text
~/.dotfiles-mac/doom-emacs-lsp/
├── .stow-local-ignore   # Impede o Stow de linkar os scripts e o README em ~/
├── install.sh           # Instalador completo (MacPorts, Node, Stow, Doom)
├── update.sh            # Script de atualização de pacotes e sistema
├── build-grammars.sh    # Compila as gramáticas tree-sitter
├── README.md            # Documentação
└── .config/
    └── doom/
        ├── config.el    # Base (PATH, tema, interface) e carrega os módulos abaixo
        ├── +treesit.el  # Tree-sitter e checagem das gramáticas
        ├── +lsp.el      # lsp-mode, Astro (astro-ls) e Tailwind
        ├── +biome.el    # Formatação, lint e diagnóstico do Biome
        ├── +org.el      # Org-mode (capturas e atalhos)
        ├── init.el      # Módulos ativos do Doom Emacs
        └── packages.el  # Pacotes externos (Catppuccin, astro-ts-mode, lsp-biome, lsp-tailwindcss)
```

## 🚀 Recursos Configurados

* **Emacs 31.1 + Tree-sitter Nativo:** Realce de sintaxe e análise estrutural ultrarrápida para Astro, TSX, TypeScript, JavaScript, HTML, CSS e JSON.
* **lsp-mode (módulo `lsp` do Doom):** Conecta os servidores do **Astro**, **TypeScript 6** e **Tailwind CSS** ao mesmo tempo no mesmo buffer (o Tailwind roda como add-on via `lsp-tailwindcss`). Ajustes leves para 8 GB de RAM (sem lens e sem breadcrumb, `lsp-idle-delay` 0.5, file watchers sem `.astro`, `dist`, `.vercel` e `.next`). A formatação nunca passa pelo LSP (`+format-with-lsp` desligado): quem formata é sempre o Biome via Apheleia.
* **Linter + Formatador BiomeJS:** Formatação ao salvar via `apheleia` (inclui `.astro`) e lint/diagnósticos em tempo real via `lsp-biome` (cliente do lsp-mode que roda `biome lsp-proxy` junto dos outros servidores, só em projetos com `biome.json`). Tudo segue o `biome.json` do projeto; em projetos sem ele o Biome não roda. YAML fica sem formatador. HTML (`.html` e a marcação dos `.astro`) só é formatado se o `biome.json` do projeto tiver `html.experimentalFullSupportEnabled: true` (veja a seção abaixo).
* **Tema Catppuccin:** Sabor *Mocha* ativo por padrão.
* **Org-mode Produtivo:** Templates de captura rápida (`SPC X`) e atalhos dedicados (`SPC n`).

## 🛠️ Instalação

1. Dê permissão de execução aos scripts:
   ```bash
   cd ~/.dotfiles-mac/doom-emacs-lsp
   chmod +x install.sh update.sh
   ```

2. *(Se precisar)* ajuste a versão do Node.js em `NODE_VERSION` no topo do `install.sh` e do `update.sh` (hoje `22`). O Node vem do **nvm** (porta `nvm` do MacPorts): o instalador roda `sudo port install nvm`, carrega `/opt/local/share/nvm/init-nvm.sh`, executa `nvm install 22` e define a versão como padrão.

3. Execute o instalador:
   ```bash
   ./install.sh
   ```

4. *(Opcional)* Adicione o CLI do `doom` ao seu `~/.zshrc`:
   ```bash
   echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

> **🌳 Lembrete: gramáticas tree-sitter.** O Emacs **não** instala gramáticas sozinho (`treesit-auto-install-grammar` está em `never`). Todas (`astro`, `bash`, `css`, `html`, `javascript`, `json`, `yaml`, `typescript` e `tsx`) vêm do `build-grammars.sh`, que o `install.sh` já executa.
>
> Se ocorrer algo parecido com isto, **rode o script de instalação**:
> * um `.astro` abre só como "Astro", sem tree-sitter, e sem realce;
> * aparece "Tree-sitter for … isn't available" ou o aviso "Gramáticas faltando" ao abrir o primeiro arquivo;
> * depois de atualizar o Emacs ou o macOS, as gramáticas deixam de carregar.
>
> ```bash
> cd ~/.dotfiles-mac/doom-emacs-lsp
> ./build-grammars.sh            # recompila todas (rápido); ou só uma: ./build-grammars.sh tsx
> ./install.sh                   # alternativa: refaz a instalação completa
> ```
>
> **Se o erro continuar depois de rodar o script**, confira de onde o Emacs procura (o aviso "Gramáticas faltando" já mostra a pasta esperada, se ela existe e se está no `treesit-extra-load-path`):
> * no terminal: `ls ~/.local/lib/tree-sitter` deve listar nove arquivos `libtree-sitter-*.dylib` (astro, bash, css, html, javascript, json, typescript, tsx e yaml);
> * no Emacs: `M-: treesit-extra-load-path` deve incluir `~/.local/lib/tree-sitter`;
> * o `build-grammars.sh` também cria links em `~/.config/emacs/.local/cache/tree-sitter` (pasta que o Emacs sempre consulta no Doom), como reserva caso o `treesit-extra-load-path` não inclua `~/.local/lib/tree-sitter`;
> * reinicie o Emacs por completo (`SPC q r` não recarrega o `treesit-extra-load-path` de uma sessão antiga).
>
> O `build-grammars.sh` lista no fim quais gramáticas estão `ok` ou `FALTA`. Depois reinicie o Emacs e confira com `M-: (mapcar #'treesit-language-available-p '(astro css tsx))` (tudo deve ser `t`) ou com `M-x my/treesit-checar-gramaticas`.

> **📝 Nota Pós-Instalação (Ícones):** caso os ícones apareçam como quadrados vazios no macOS, instale a fonte **Symbols Nerd Font** (disponível em [nerdfonts.com](https://nerdfonts.com)) pelo Catálogo de Fontes (Font Book).

## ⌨️ Atalhos Principais

| Atalho | Ação |
| :--- | :--- |
| `SPC f f` | Buscar arquivo no projeto |
| `SPC c x` | Listar erros e avisos do Linter (BiomeJS + LSP) |
| `SPC c a` | Code Actions (correções rápidas do LSP/Biome) |
| `SPC c B` | Biome: aplicar todas as correções automáticas (`lsp-biome-fix-all`) |
| `SPC c O` | Biome: organizar imports (`lsp-biome-organize-imports`) |
| `SPC c L` | Biome: lint do projeto inteiro (buffer de compilação) |
| `SPC c D` | Biome: diagnóstico (qual Biome, qual `biome.json`, versão, avisos) |
| `SPC g g` | Abrir Git (Magit) |
| `SPC o t` | Abrir terminal integrado (vterm) |
| `SPC X` | Captura rápida no Org-mode (`t` Tarefa, `d` Diário, `p` Projeto) |
| `SPC n i` / `d` | Abrir `inbox.org` ou `diario.org` |

## 🧾 Log da instalação

No final, o `install.sh` roda `doom sync --env` e `doom doctor` e grava a saída de ambos (também mostrada na tela) em `~/.local/state/doom-emacs/install-AAAAMMDD-HHMMSS.log`. Se o `doom doctor` apontar problemas, o script avisa em vez de parar. Para ver só o que importa: `grep -n -i 'error\|warn' ~/.local/state/doom-emacs/install-*.log`.

## 🧱 Pacotes do MacPorts

Além do Emacs, o `install.sh` instala `ripgrep`, `fd`, `git`, `stow`, `nvm`, `cmake`, `libtool`, `shfmt` e `shellcheck`. O `cmake` e o `libtool` servem para compilar o `vterm` (`SPC o t`); o `shfmt` e o `shellcheck`, para formatar e checar shell scripts.

## 📦 Pacotes npm globais em `~/.local`

O `install.sh` instala `typescript@6`, `typescript-language-server`, `@astrojs/language-server`, `@tailwindcss/language-server`, `@biomejs/biome`, `stylelint` e `js-beautify` em `~/.local` (`npm install -g --prefix ~/.local`), **sem sudo**. Assim eles não dependem do MacPorts nem da versão do Node do nvm e continuam lá quando o Node é atualizado. O `update.sh` atualiza no mesmo lugar. O Emacs já inclui `~/.local/bin` no `exec-path`; para usar os comandos no terminal, o `~/.zshrc` precisa de `export PATH="$HOME/.local/bin:$PATH"` (o instalador avisa se faltar).

Se você já tinha esses pacotes instalados com `sudo npm install -g` (em `/opt/local`), a cópia de `~/.local/bin` passa na frente; para limpar as antigas: `sudo npm uninstall -g typescript typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome stylelint js-beautify`.

### Node (nvm) no Emacs e no terminal

* **Emacs:** o app gráfico não carrega o nvm, então o `install.sh` cria links estáveis `~/.local/bin/node`, `npm` e `npx` apontando para a versão ativa do nvm (o `update.sh` os refaz depois de `nvm install 22`). Os servidores LSP usam esse `node`.
* **Terminal:** adicione ao `~/.zshrc` a linha `source /opt/local/share/nvm/init-nvm.sh` para usar `nvm`, `node` e `npm` normalmente.
* Não defina `prefix` no `~/.npmrc`: o nvm não funciona com essa opção. Os pacotes globais usam `--prefix ~/.local` direto na linha de comando.

## 🧰 Biome no projeto

O Biome global (instalado pelo `install.sh`) serve de reserva. Em cada projeto, instale a mesma versão do `$schema` do `biome.json`:

```bash
npm i -D --save-exact @biomejs/biome
```

## 🌐 Formatação de HTML

O Biome só formata a marcação HTML (em `.astro` e `.html`) com o suporte a HTML ligado. Sem isso, nos `.astro` ele formata apenas o frontmatter e deixa o `<div>…</div>` como está, e os `.html` ficam sem formatação. Adicione ao `biome.json` do projeto:

```json
"html": {
	"experimentalFullSupportEnabled": true,
	"formatter": { "enabled": true },
	"linter": { "enabled": true }
}
```

O Emacs detecta essa chave sozinho: com ela, `.html` passa a ser formatado ao salvar; sem ela, o Apheleia pula o arquivo em vez de dar erro.

O Emacs também lê o `indentStyle` do `biome.json`: com `"tab"`, os buffers `.astro`, `.ts`, `.tsx`, `.js`, `.css` e `.json` passam a indentar com tabs (largura 2), para não divergir do que o Biome grava ao salvar. Para aplicar o Biome de uma vez em um projeto que ainda usa espaços (um commit grande, mas só uma vez): `npx biome format --write src`.

## 🩺 Diagnóstico

* `M-x my/treesit-checar-gramaticas`: lista as gramáticas tree-sitter que faltam. Roda sozinho ao abrir o primeiro arquivo e mostra um aviso se algo estiver faltando.
* `SPC c D` (`my/biome-diagnostico`): mostra o Biome em uso (projeto ou global) e sua versão, o `biome.json` encontrado, a indentação, se o suporte a HTML está ligado, se o Biome roda no buffer atual e avisos (versão diferente do `$schema`, versões com desalinhamento de JSX no Astro: 2.5.14, 2.6.0 e 2.6.1).

O `biome.json` é lido como JSON de verdade (comentários e `extends` relativos incluídos) e fica em cache até o arquivo mudar.

## 🔗 Stow: migrando do pacote antigo `doom-emacs`

O `.stow-local-ignore` deste pacote impede o Stow de linkar `install.sh`, `update.sh`, `build-grammars.sh` e `README.md` em `~/`. Se o pacote antigo já criou esses links, remova-os antes de stowar o novo:

```bash
cd ~/.dotfiles-mac
stow -D doom-emacs 2>/dev/null || true      # se a pasta antiga ainda existir
for f in install.sh update.sh build-grammars.sh; do
  [ -L "$HOME/$f" ] && rm "$HOME/$f"        # só remove se for link simbólico
done
stow -v doom-emacs-lsp
```

## 🔌 Trocar Eglot por lsp-mode

Depois de aplicar estes arquivos, rode `doom sync` e reinicie o Emacs. Na primeira vez em CSS/HTML/JSON o lsp-mode pode oferecer a instalação do servidor correspondente; aceite com `y`.

## 🔄 Manutenção

Para atualizar o MacPorts, pacotes do Node (mantendo o TypeScript 6), links do Stow e o Doom Emacs de uma só vez:
```bash
./update.sh
```
