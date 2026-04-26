vim.pack.add({
  "https://github.com/jake-stewart/multicursor.nvim",
}, { confirm = false })

local mc = require("multicursor-nvim")

mc.setup()

-- Add or skip cursor above/below the main cursor.
vim.keymap.set({ "n", "x" }, "<C-M-up>", function() mc.lineAddCursor(-1) end)
vim.keymap.set({ "n", "x" }, "<C-M-down>", function() mc.lineAddCursor(1) end)
vim.keymap.set({ "n", "x" }, "<C-M-B>", function() mc.lineSkipCursor(-1) end)
vim.keymap.set({ "n", "x" }, "<C-M-S>", function() mc.lineSkipCursor(1) end)

-- Add or skip adding a new cursor by matching word/selection
vim.keymap.set({ "n", "x" }, "<C-N>", function() mc.matchAddCursor(1) end)
vim.keymap.set({ "n", "x" }, "<C-S>", function() mc.matchSkipCursor(1) end)

-- Mappings defined in a keymap layer only apply when there are
-- multiple cursors. This lets you have overlapping mappings.
mc.addKeymapLayer(function(layerSet)
  -- Delete the main cursor.
  layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

  -- Enable and clear cursors using escape.
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

-- Customize how cursors look.
vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
