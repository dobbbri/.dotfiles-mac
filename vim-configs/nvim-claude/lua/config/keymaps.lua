-------------------------------------------------------
-- ATALHOS GERAIS (não dependem de plugin nenhum)
-------------------------------------------------------
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Sair do modo insert" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Salvar arquivo" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Fechar janela" })
map("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Limpar destaque de busca" })

-- Navegação entre janelas
map("n", "<C-h>", "<C-w>h", { desc = "Ir para janela à esquerda" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir para janela à direita" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir para janela abaixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir para janela acima" })

-- Manter cursor centralizado ao navegar
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Mover linha(s)/seleção (sem plugin — comando :m nativo do Vim)
map("n", "<M-j>", ":m .+1<CR>==", { desc = "Mover linha atual pra baixo" })
map("n", "<M-k>", ":m .-2<CR>==", { desc = "Mover linha atual pra cima" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover seleção pra baixo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover seleção pra cima" })
