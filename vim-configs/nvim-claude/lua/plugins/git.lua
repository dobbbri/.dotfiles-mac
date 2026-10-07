return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local map = function(mode, keys, fn, desc)
        vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = desc })
      end
      map("n", "]c", function() gs.nav_hunk("next") end, "Próximo hunk git")
      map("n", "[c", function() gs.nav_hunk("prev") end, "Hunk git anterior")
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame da linha")
    end,
  },
}
