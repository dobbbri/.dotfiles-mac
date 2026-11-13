require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _) return name == ".git" or name == ".." or name == ".DS_Store" end,
  },
  keymaps = {
    ["<ESC>"] = "actions.close",
    ["q"] = "actions.close",
    ["-"] = { "actions.parent", mode = "n" },
    ["."] = { "actions.toggle_hidden", mode = "n" },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil", -- Adjust if Oil uses a specific file type identifier
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
