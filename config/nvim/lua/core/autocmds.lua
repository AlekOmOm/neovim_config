# ~/.config/nvim/lua/core/autocmds.lua
local autocmd = vim.api.nvim_create_autocmd

-- File running commands
autocmd('FileType', {
  pattern = {'python', 'java', 'cs', 'lua', 'javascript', 'typescript', 'rust'},
  callback = function()
    local filetype = vim.bo.filetype
    local cmd = {
      python = ':!python %',
      java = ':!javac % && java %:r',
      cs = ':!dotnet run %',
      lua = ':!lua %',
      javascript = ':!node %',
      typescript = ':!ts-node %',
      rust = ':!cargo run'
    }
    
    if cmd[filetype] then
      vim.keymap.set('n', '<F5>', cmd[filetype] .. '<CR>', { buffer = true })
    end
  end
})
