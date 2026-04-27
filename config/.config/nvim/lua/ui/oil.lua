require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _) return name == ".git/" end,
  },
  keymaps = {
    ["<ESC>"] = "actions.close",
    ["q"] = "actions.close",
  },
})
