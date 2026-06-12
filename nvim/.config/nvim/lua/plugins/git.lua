-- Git: gitsigns for hunk navigation, staging, blame, and diff.
return {
  {
    'lewis6991/gitsigns.nvim',
    config = function(_, opts)
      require('gitsigns').setup(opts)

      local gs = require('gitsigns')
      local map = vim.keymap.set

      map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
      map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
      map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
      map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
      map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
      map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line' })
      map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })
      map('n', '<leader>gb', gs.toggle_current_line_blame, { desc = 'Toggle git blame' })
      map('n', '<leader>gw', gs.toggle_word_diff, { desc = 'Toggle word diff' })
    end,
  },
}