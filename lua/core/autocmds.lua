--# ~/.config/nvim/lua/core/autocmds.lua
-- Import the paths utility module
local paths = require('utils.paths')
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

-- Auto-create directories when saving files
local augroup = vim.api.nvim_create_augroup("AutoMkdir", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    -- Get the directory of the current buffer
    local dir = vim.fn.expand("<afile>:p:h")

    -- Check if the directory exists
    if vim.fn.isdirectory(dir) == 0 then
      -- Create the directory and all parent directories using our paths utility
      paths.ensure_dir(dir)

      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to create directory: " .. dir, 1)
        return
      end
    end
  end,
})
