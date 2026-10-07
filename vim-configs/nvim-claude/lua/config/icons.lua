-- Ícones compartilhados entre vários plugins (diagnóstico, bufferline, dap).
-- require("config.icons") de onde precisar.
return {
  error = "󰅚 ", -- U+F015A
  warn  = "󰀪 ", -- U+F002A
  info  = "󰋽 ", -- U+F02FD
  hint  = "󰌶 ", -- U+F0336
  -- usados só pelo nvim-dap (sinais de breakpoint/execução)
  breakpoint = "󰝥 ",
  breakpoint_cond = "󰝥 ",
  stopped = "󰅁 ",
}
