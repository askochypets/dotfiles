-- Format on save and linters
return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting   -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters
    local code_actions = null_ls.builtins.code_actions

    -- list of formatters & linters for mason to install
    require('mason-null-ls').setup {
      ensure_installed = {
        'checkmake',
        'prettierd',  -- ts/js/html/css/json/md formatter
        'eslint_d',   -- ts/js/react linter
        'stylua',     -- lua formatter
        'shfmt',      -- shell formatter
        'goimports',  -- go formatter
        'gofumpt',    -- go formatter
      },
      -- auto-install configured formatters & linters (with null-ls)
      automatic_installation = true,
    }

    local sources = {
      -- JavaScript / TypeScript / React / HTML / CSS
      formatting.prettierd.with {
        filetypes = {
          'javascript', 'javascriptreact',
          'typescript', 'typescriptreact',
          'html', 'css', 'json', 'yaml', 'markdown',
        },
      },
      diagnostics.eslint_d,
      code_actions.eslint_d,

      -- Go
      formatting.goimports,
        formatting.gofumpt,

      -- Lua / Shell
      formatting.stylua,
      formatting.shfmt.with { args = { '-i', '4' } },

      diagnostics.checkmake,
      formatting.terraform_fmt,

      require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
      require 'none-ls.formatting.ruff_format',
    }

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
    null_ls.setup {
      -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
      sources = sources,
      -- you can reuse a shared lspconfig on_attach callback here
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { async = false }
            end,
          })
        end
      end,
    }
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format file" })
  end,
}
