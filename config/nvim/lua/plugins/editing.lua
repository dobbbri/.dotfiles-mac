return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  -- visual-multi tem keymaps próprios definidos no load do plugin (não dá
  -- pra prever toda tecla de antemão pra usar "keys"), então VeryLazy é o
  -- gatilho seguro aqui.
  { "yaocccc/visual-multi.nvim", event = "VeryLazy", opts = {} },
}
