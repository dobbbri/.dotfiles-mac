local wk = require("which-key")

wk.setup()

wk.add({
  { "-", "<CMD>Oil<CR>", desc = "Edit Files (Oil)" },

  { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
  { "gr", vim.lsp.buf.references, desc = "Show References" },
  { "K", vim.lsp.buf.hover, desc = "Hover Docs" },

  { "<leader>d", group = "Diagnostics" },
  { "<leader>dl", vim.diagnostic.setloclist, desc = "List Diagnostics" },
  { "<leader>df", vim.diagnostic.open_float, desc = "Float Error" },

  { "<leader>c", group = "Code" },
  { "<leader>cf", "<CMD>Format<CR>", desc = "Format File" },
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol" },

  { "<leader>f", group = "Find" }, -- Grouping for your fzf-lua
  { "<leader>ff", "<CMD>FzfLua files<CR>", desc = "Find Files" },
  { "<leader>fg", "<CMD>FzfLua live_grep<CR>", desc = "Grep Text" },
  { "<leader><space>", "<CMD>FzfLua buffers<CR>", desc = "Opened Buffers" },

  { "<leader>g", group = "Git" },
  { "<leader>gs", "<CMD>Gitsigns stage_hunk<CR>", desc = "Stage Hunk" },
  { "<leader>gr", "<CMD>Gitsigns reset_hunk<CR>", desc = "Reset Hunk" },
  { "<leader>gp", "<CMD>Gitsigns preview_hunk<CR>", desc = "Preview Hunk" },
  { "<leader>gb", "<CMD>Gitsigns blame_line --full'<CR>", desc = "Blame Line" },

  { "<leader>r", group = "Replace" },
  { "<leader>ra", "<CMD>GrugFar<CR>", desc = "Replace in projec", mode = { "n", "v" } },
  { "<leader>rr", ":%s///gcI<Left><Left><Left><Left><Left>", desc = "replace in current buffer" },

  { "<leader>?", "<CMD>WhichKey<CR>", desc = "Show all keymaps" },

  { "<leader>x", "<CMD>bd<CR>", desc = "Close current buffer" },
  { "<leader>X", "<CMD>%bd<CR>", desc = "Close all buffers" },

  { "<leader>q", "<CMD>q<CR>", desc = "Quit" },
  { "<leader>Q", "<CMD>qa<CR>", desc = "Quit All" },

  { "<Esc>", "<CMD>nohlsearch<CR>", desc = "Clear Highlight", silent = true },

  { "<C-h>", "<C-w>h", desc = "Go Left" },
  { "<C-j>", "<C-w>j", desc = "Go Down" },
  { "<C-k>", "<C-w>k", desc = "Go Up" },
  { "<C-l>", "<C-w>l", desc = "Go Right" },

  { "<C-Up>", "<CMD>resize +2<CR>", desc = "Increase Height" },
  { "<C-Down>", "<CMD>resize -2<CR>", desc = "Decrease Height" },
  { "<C-Left>", "<CMD>vertical resize -2<CR>", desc = "Decrease Width" },
  { "<C-Right>", "<CMD>vertical resize +2<CR>", desc = "Increase Width" },

  { "J", ":m '>+1<CR>gv=gv", desc = "Move Lines Down", mode = "v" },
  { "K", ":m '<-2<CR>gv=gv", desc = "Move Lines Up", mode = "v" },
  { "k", "v:count == 0 ? 'gk' : 'k'", expr = true, desc = "Up (wrapped)" },
  { "j", "v:count == 0 ? 'gj' : 'j'", expr = true, desc = "Down (wrapped)" },

  { "H", "^", desc = "Start of Line", mode = { "n", "x", "o" } },
  { "L", "g_", desc = "End of Line", mode = { "n", "x", "o" } },

  { "<Tab>", "<CMD>bprevious<CR>", desc = "Prev Buffer" },
  { "<S-Tab>", "<CMD>bnext<CR>", desc = "Next Buffer" },

  { "YY", "va{Vy", desc = "Yank Block {}" },
  { "<C-a>", "ggVG", desc = "Select All" },

  { "<Tab>", "<gv", desc = "Indent Left", mode = "v" },
  { "<Backspace>", ">gv", desc = "Indent Right", mode = "v" },

  { "p", '"_dP', desc = "Paste (no yank)", mode = "v" },

  { "<Esc><Esc>", "<C-\\><C-n>", desc = "Exit Terminal Mode", mode = "t" },
  { "<C-h>", "<CMD>wincmd h<CR>", desc = "Go Left", mode = "t" },
  { "<C-j>", "<CMD>wincmd j<CR>", desc = "Go Down", mode = "t" },
  { "<C-k>", "<CMD>wincmd k<CR>", desc = "Go Up", mode = "t" },
  { "<C-l>", "<CMD>wincmd l<CR>", desc = "Go Right", mode = "t" },
})

