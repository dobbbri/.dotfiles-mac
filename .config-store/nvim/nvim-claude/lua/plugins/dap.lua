-- DAP: debug de verdade (breakpoints, step into/over/out, variáveis,
-- watches, call stack). mason-nvim-dap instala e registra o adaptador
-- "js-debug-adapter" (derivado do vscode-js-debug, o mesmo motor que o
-- VS Code usa) via Mason — nada de clonar/compilar nada manualmente.
-- Carrega só quando você de fato usa algum atalho de debug.
local icons = require("config.icons")

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "williamboman/mason.nvim",
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = { "williamboman/mason.nvim" },
      opts = {
        ensure_installed = { "js-debug-adapter" },
        automatic_installation = true,
        handlers = {},
      },
    },
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    "theHamsta/nvim-dap-virtual-text",
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    {
      "<leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input("Condição: ")) end,
      desc = "Breakpoint condicional",
    },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continuar / iniciar debug" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Abrir REPL do debug" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Repetir última sessão de debug" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminar debug" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Abrir/fechar painel de debug (dap-ui)" },
    -- aliases no estilo VS Code, pra quem já tem o hábito
    { "<F5>", function() require("dap").continue() end, desc = "Debug: continuar/iniciar" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Sinais customizados na gutter (mesmo estilo dos ícones de
    -- diagnóstico já usados no resto da config).
    vim.fn.sign_define("DapBreakpoint", { text = icons.breakpoint, texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointCondition", { text = icons.breakpoint_cond, texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DapStopped", { text = icons.stopped, texthl = "DiagnosticInfo", linehl = "Visual" })

    dapui.setup()
    require("nvim-dap-virtual-text").setup({})

    -- Abre/fecha o painel (variáveis, call stack, breakpoints, watches)
    -- automaticamente junto com a sessão de debug.
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- Launch configs pra JS/TS/Node. "pwa-node" vem do js-debug-adapter
    -- (mason-nvim-dap já registra o adapter; só faltam as configurations).
    for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      dap.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Rodar arquivo atual (node)",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Conectar a processo Node existente",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug npm run dev",
          runtimeExecutable = "npm",
          runtimeArgs = { "run", "dev" },
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          console = "integratedTerminal",
        },
      }
    end
    -- Astro: o servidor de dev roda em Node por baixo do Vite, então debug
    -- de código server-side (endpoints, middleware, .ts) funciona via as
    -- mesmas configs acima; breakpoint DENTRO de um .astro em si não é
    -- suportado pelo js-debug-adapter (ele debuga JS/TS, não o template
    -- compilado do Astro).
  end,
}
