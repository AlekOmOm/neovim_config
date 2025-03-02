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

-- Add this to your autocmds.lua
vim.api.nvim_create_autocmd("BufWriteCmd", {
    pattern = "*",
    callback = function()
        local modified = vim.bo.modified


        if modified then
            vim.cmd("write")
        else
            -- Silently proceed without error message
            vim.cmd("noautocmd write")
        end
        return true -- Prevent the default BufWriteCmd behavior
    end
})

