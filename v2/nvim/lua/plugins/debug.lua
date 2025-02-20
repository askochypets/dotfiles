return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    {
      'williamboman/mason.nvim',
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, 'js-debug-adapter')
      end,
    },
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  opts = function()
    local dap = require 'dap'
    if not dap.adapters['pwa-node'] then
      -- Setup for `pwa-node` adapter
      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            -- Update this path to point to the correct `js-debug-adapter` location
            require('mason-registry').get_package('js-debug-adapter'):get_install_path() ..
            '/js-debug/src/dapDebugServer.js',
            '${port}',
          },
        },
      }
    end

    -- Ensure `node` adapter is mapped to `pwa-node`
    if not dap.adapters['node'] then
      dap.adapters['node'] = function(cb, config)
        if config.type == 'node' then
          config.type = 'pwa-node'
        end
        local nativeAdapter = dap.adapters['pwa-node']
        if type(nativeAdapter) == 'function' then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    -- Supported JavaScript and TypeScript filetypes
    local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

    -- Configure dap for each JavaScript-related filetype
    for _, language in ipairs(js_filetypes) do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch NX Serve (handl)',
          program = '${workspaceFolder}/node_modules/.bin/nx',
          args = { 'serve', 'handl' }, -- Command to run `nx serve auth`
          cwd = '${workspaceFolder}',
          runtimeExecutable = 'node',
          console = 'integratedTerminal',
          restart = true, -- Automatically restart the debugger if the process crashes
        },
        {
          -- Launch configuration to start the npm script
          type = 'pwa-node',
          request = 'launch',
          name = 'Run tsx debugger',
          cwd = '${workspaceFolder}/api',
          program = '${workspaceFolder}/api/src/server.ts', -- Full path to server file
          runtimeExecutable = 'tsx',
          console = 'integratedTerminal',                   -- Run command in integrated terminal
          skipFiles = { '<node_internals>/**' },            -- Skip internal Node.js files
          resolveSourceMapLocations = {
            '${workspaceFolder}/api/**',
            '!**/node_modules/**',
          },                             -- Optional: refine source map locations for clarity
          attachSimplePort = 9229,       -- Optional: force debugger to only use a specific port
          runtimeArgs = { '--inspect' }, -- Leave runtime args empty unless absolutely needed
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal', -- Use Neovim's integrated terminal for `node-terminal` requirement
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Auto Attach to Process',
          cwd = vim.fn.getcwd(),
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to Process',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        -- Divider for the launch.json derived configs
        {
          name = '----- ↓ launch.json configs ↓ -----',
          type = '',
          request = 'launch',
        },
      }
    end
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        -- 'delve',
        'js-debug-adapter',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    -- require('dap-go').setup()
  end,
}
