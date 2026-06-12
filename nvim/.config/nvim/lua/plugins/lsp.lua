-- LSP: server configuration, Mason installer, formatter (conform), linting.
return {
  -- Mason MUST load first and eagerly
  {
    'mason-org/mason.nvim',
    lazy = false,
    priority = 100,
    opts = {},
  },

  -- Mason tool installer (depends on mason being ready)
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    config = function()
      local lsp_to_mason = {
        lua_ls = 'lua-language-server',
        pyright = 'pyright',
        -- ts_ls = 'typescript-language-server',
      }
      local ensure_installed = { 'lua-language-server', 'marksman', 'stylua', 'prettier', 'python-lsp-server', 'pyright' }
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    end,
  },

  -- Fidget
  {
    'j-hui/fidget.nvim',
    opts = {},
  },

  -- Conform
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>=',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        -- javascript = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },

  -- Main LSP config
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'mason-org/mason.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'j-hui/fidget.nvim',
      'stevearc/conform.nvim',
      'saghen/blink.cmp',
      'folke/snacks.nvim',
    },
    config = function()
      -- require('mason').setup()
      -- require('fidget').setup()

      local servers = {
        -- clangd = {},
        -- gopls = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'basic',
                autoSerachPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'workspace',
              },
            },
          },
        },
        pyslp = {
          capabilites = {
            hoverProvider = false,
            completionProvider = false,
            definitionProvider = false,
            referencesProvider = false,
            renameProvider = false,
            signatureHelpProvider = false,
          },
          settings = {
            pylsp = {

              pyflakes = { enabled = false },
              pycodestyle = { enabled = false },
              pylint = { enabled = false },
              mccabe = { enabled = false },

              black = { enabled = true },
              isort = { enabled = true, profile = 'black' },

              rope_autoimport = { enabled = true },
              rope_completion = { enabled = false },
            },
          },
        },
        -- rust_analyzer = {},
        -- ts_ls = {}
        lua_ls = {
          settings = { Lua = { completion = { callSnippet = 'Replace' } } },
        },
        marksman = {},
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      for name, cfg in pairs(servers) do
        local server = vim.tbl_deep_extend('force', {}, cfg)
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config[name] = server
        vim.lsp.enable(name)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', function()
            require('snacks').picker.lsp_references()
          end, '[G]oto [R]eferences')
          map('gri', function()
            require('snacks').picker.lsp_implementations()
          end, '[G]oto [I]mplementation')
          map('grd', function()
            require('snacks').picker.lsp_definitions()
          end, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', function()
            require('snacks').picker.lsp_symbols()
          end, 'Open Document Symbols')
          map('gW', function()
            require('snacks').picker.lsp_workspace_symbols()
          end, 'Open Workspace Symbols')
          map('grt', function()
            require('snacks').picker.lsp_type_definitions()
          end, '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local hl_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(d)
            return d.message
          end,
        },
      }
    end,
  },
}
