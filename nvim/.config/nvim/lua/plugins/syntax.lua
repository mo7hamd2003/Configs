-- Treesitter context UI on top of Neovim 0.12 built-in treesitter.

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup {
        prefer_git = true,
        ensure_installed = {
          'markdown',
          'markdown_inline',
          'lua',
          'python',
          'bash',
        },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { max_lines = 3 },
  },
}
