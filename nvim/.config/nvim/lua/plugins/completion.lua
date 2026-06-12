-- Completion: blink.cmp + LuaSnip (no Copilot)
return {
  -- LuaSnip: snippet engine with jsregexp build step
  {
    'L3MON4D3/LuaSnip',
    version = '2.*',
    build = (vim.fn.has('win32') == 0 and vim.fn.executable('make') == 1)
      and 'make install_jsregexp'
      or nil,
    opts = {},
  },

  -- lazydev.nvim: Neovim Lua API completions
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },

  -- blink.cmp: completion engine
  {
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      signature = { enabled = true },
    },
  },
}