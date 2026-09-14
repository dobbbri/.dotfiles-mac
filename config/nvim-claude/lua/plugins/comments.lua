-- ts-comments.nvim: estende o "gc"/"gcc" NATIVO do Neovim (0.10+) com
-- commentstring correto via treesitter em contexto embutido (ex: <script>
-- dentro de .astro, JSX dentro de .tsx). Não precisa de engine própria
-- porque o Neovim já comenta nativamente, só faltava a detecção de
-- linguagem certa.
return { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} }
