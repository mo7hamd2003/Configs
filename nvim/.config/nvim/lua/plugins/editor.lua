-- Editor utilities: autopairs, indent guides, linting, highlighting, auto-save,
-- guess-indent, todo-comments, img-clip, undotree, wakatime, suda, mkdnflow, visual-multi,
-- grammarly LSP.
return {
  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        -- markdown = { 'markdownlint-cli2' },
      }
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },

  -- Color highlighting
  {
    'brenoprata10/nvim-highlight-colors',
    opts = { render = 'background' },
  },

  -- Auto-save
  {
    'Pocco81/auto-save.nvim',
    opts = {},
  },

  -- Auto-detect tab/space indentation
  {
    'NMAC427/guess-indent.nvim',
    opts = {},
  },

  -- Todo comment highlights
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    opts = {
      signs = false,
      highlights = {
        multiline = true,
        multiline_pattern = '^.',
        before = '',
        keyword = 'wide_bg',
        after = 'fg',
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exlude = {},
      },
      Colors = {
        error = { 'DiagnosticError', '#DC2626' },
        warning = { 'DiagnosticWarn', '#FBBF24' },
        info = { 'DiagnosticInfo', '#2563EB' },
        hint = { 'DiagnosticHint', '#10B981' },
        default = { '#7C3AED' },
        test = { '#FF00FF' },
      },
      keywords = {
        TODO = { icon = '', color = 'info', alt = {} },
        FIX = { icon = '', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
        HACK = { icon = '', color = 'warning' },
        WARN = { icon = '', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = '', color = 'default', alt = { 'OPTION', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = '', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = '', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
    },
  },

  -- Paste images from clipboard into Markdown
  {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    config = function()
      local year = os.date '%Y'
      require('img-clip').setup {
        default = {
          dir_path = vim.fs.joinpath(vim.uv.os_homedir(), 'Pictures', 'img-clip', year),
          extension = 'png',
          template = '![$FILE_NAME_NO_EXT](/images/' .. year .. '/$FILE_NAME)',
          relative_template_path = false,
        },
        filetypes = {
          markdown = { template = '![$FILE_NAME_NO_EXT](/images/' .. year .. '/$FILE_NAME)' },
        },
      }
    end,
  },

  -- Persistent undo history tree (mapped to <F5>)
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
  },

  -- Edit files as sudo (:SudaWrite)
  {
    'lambdalisue/suda.vim',
    cmd = { 'SudaRead', 'SudaWrite' },
  },

  -- Multi-cursor (Ctrl+N)
  {
    'mg979/vim-visual-multi',
    branch = 'master',
  },

  -- Grammarly LSP for prose
  {
    'emacs-grammarly/lsp-grammarly',
    ft = { 'markdown', 'text' },
  },

  -- F# language support
  {
    'ionide/Ionide-vim',
    ft = 'fsharp',
  },

  -- Smart comment toggling
  {
    'numToStr/Comment.nvim',
    opts = {},
  },

  -- Mkdnflow for fluent navigation and management
  {
    'jakewvincent/mkdnflow.nvim',
    ft = { 'markdown' },
    config = function()
      require('mkdnflow').setup {
        modules = {
          bib = false,
          buffers = true,
          conceal = true,
          cursor = true,
          folds = true,
          foldtext = true,
          links = true,
          lists = true,
          maps = true,
          paths = true,
          tables = true,
          to_do = true,
          yaml = false,
          notebook = true,
        },
        links = {
          style = 'wiki',
          implicit_extension = 'md',
          conceal = false,
          transform_explicit = false,
        },
        to_do = {
          statuses = {
            not_started = { marker = ' ', hl_group = 'mkdnflowTodo' },
            in_progress = { marker = '-', hl_group = 'mkdnflowTodoInProgress' },
            complete = { marker = { 'x', 'X' }, hl_group = 'mkdnflowTodoComplete' },
          },
          status_order = { 'not_started', 'in_progress', 'complete' },
          status_propagation = {
            up = true,
            down = true,
          },
        },
        foldtext = {
          object_count = true,
          object_count_icon_set = 'emoji',
          object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts()
          end,
          line_count = true,
          line_percentage = true,
          word_count = false,
          title_transformer = function()
            return require('mkdnflow').foldtext.default_title_transformer
          end,
          fill_chars = {
            left_edge = '⢾⣿⣿',
            right_edge = '⣿⣿⡷',
            item_separator = ' · ',
            section_separator = ' ⣹⣿⣏ ',
            left_inside = ' ⣹',
            right_inside = '⣏ ',
            middle = '⣿',
          },
        },
        tables = {
          trim_whitespace = true,
          format_on_move = false,
          auto_extend_rows = false,
          auto_extend_cols = false,
          style = {
            cell_padding = 1,
            separator_padding = 1,
            outer_pipes = true,
          },
        },
      }
    end,
  },
}
