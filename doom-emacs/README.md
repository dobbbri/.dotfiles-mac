# Doom Emacs Dotfiles — macOS Ventura (Intel 2015 / 8GB RAM) + MacPorts

Configuração modular do **Doom Emacs** rodando sobre **GNU Emacs 31.1**, gerenciada via **GNU Stow** (`~/.dotfiles-mac/doom-emacs`). Otimizada para desenvolvimento web moderno (**Astro, React, TypeScript 6, Tailwind CSS, Node.js, BiomeJS**) e organização pessoal (**Org-mode**).

## 📁 Estrutura do Pacote Stow

```text
~/.dotfiles-mac/doom-emacs/
├── install.sh           # Instalador completo (MacPorts, Node, Stow, Doom)
├── update.sh            # Script de atualização de pacotes e sistema
├── README.md            # Documentação
└── .config/
    └── doom/
        ├── config.el    # Configurações principais, Eglot, Biome, Tailwind, Astro e Org
        ├── init.el      # Módulos ativos do Doom Emacs
        └── packages.el  # Pacotes externos (Catppuccin, astro-ts-mode, flycheck-biomejs)
```

## 🚀 Recursos Configurados

* **Emacs 31.1 + Tree-sitter Nativo:** Realce de sintaxe e análise estrutural ultrarrápida para Astro, TSX, TypeScript, JavaScript, HTML, CSS e JSON.
* **Eglot Leve (Otimizado para 8 GB RAM):** Conecta aos servidores LSP do **Astro**, **TypeScript 6** e **Tailwind CSS** sem o peso do `lsp-mode`.
* **Linter + Formatador BiomeJS:** Formatação instantânea ao salvar via `apheleia` e linting em tempo real encadeado após o Eglot via `flycheck-biomejs`.
* **Tema Catppuccin:** Sabor *Mocha* ativo por padrão.
* **Org-mode Produtivo:** Templates de captura rápida (`SPC X`) e atalhos dedicados (`SPC n`).

## 🛠️ Instalação

1. Dê permissão de execução aos scripts:
   ```bash
   cd ~/.dotfiles-mac/doom-emacs
   chmod +x install.sh update.sh
   ```

2. Execute o instalador:
   ```bash
   ./install.sh
   ```

3. *(Opcional)* Adicione o CLI do `doom` ao seu `~/.zshrc`:
   ```bash
   echo 'export PATH="HOME/.config/emacs/bin:PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

> **📝 Nota Pós-Instalação (Gramática do Astro & Ícones):**
> 1. **Gramática Astro:** As gramáticas de CSS, HTML, JS, JSON, TypeScript e TSX já vêm instaladas pelo MacPorts. Na primeira abertura do Emacs, instale apenas a gramática do Astro executando `M-x treesit-install-language-grammar`, digitando `astro` e pressionando `Enter`.
> 2. **Ícones da Interface:** Caso os ícones apareçam como quadrados vazios no macOS, instale a fonte **Symbols Nerd Font** (disponível em [nerdfonts.com](https://nerdfonts.com)) pelo Catálogo de Fontes (Font Book).

## ⌨️ Atalhos Principais

| Atalho | Ação |
| :--- | :--- |
| `SPC f f` | Buscar arquivo no projeto |
| `SPC c x` | Listar erros e avisos do Linter (BiomeJS + Eglot) |
| `SPC c a` | Code Actions (correções rápidas do LSP/Biome) |
| `SPC g g` | Abrir Git (Magit) |
| `SPC o t` | Abrir terminal integrado (vterm) |
| `SPC X` | Captura rápida no Org-mode (`t` Tarefa, `d` Diário, `p` Projeto) |
| `SPC n i` / `d` | Abrir `inbox.org` ou `diario.org` |

## 🔄 Manutenção

Para atualizar o MacPorts, pacotes do Node (mantendo o TypeScript 6), links do Stow e o Doom Emacs de uma só vez:
```bash
./update.sh
```
