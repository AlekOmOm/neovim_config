--# ~/.config/nvim/lua/core/autocmds.lua
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
      -- Create the directory and all parent directories
      vim.fn.mkdir(dir, "p")
      vim.notify("Created directory: " .. dir, "info")
    end
  end,
})
