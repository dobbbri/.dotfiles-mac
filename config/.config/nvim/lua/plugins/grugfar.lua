local GrugFar = require("grug-far")
GrugFar.setup({
  showCompactInputs = true,
})

vim.keymap.set("n", "<leader>rp", function() GrugFar.open({ transient = true }) end, { desc = "Replace in project" })
vim.keymap.set(
  "n",
  "<leader>rb",
  function() GrugFar.open({ prefills = { paths = vim.fn.expand(" % ") } }) end,
  { desc = "Replace in buffer" }
)
