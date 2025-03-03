-- ~/.config/nvim/lua/utils/init_file.lua
local M = {}

function M.init_empty_file(file_path)

  local quit_on_success = true

  -- Get the directory from the file path
  local dir = vim.fn.fnamemodify(file_path, ":h")
  
  -- Create directory structure if it doesn't exist
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
    if vim.fn.isdirectory(dir) == 0 then
      vim.notify("Failed to create directory: " .. dir, 0) -- ERROR level only
      return false
    end
  end
  
  -- Check if the file needs to be created
  if vim.fn.filereadable(file_path) == 0 then
    -- File doesn't exist, create it
    local file = io.open(file_path, "w")
    if file then
      file:close()
    else
      vim.notify("Failed to create file: " .. file_path, 0) -- ERROR level
      return false
    end
  end
  
  -- Exit Neovim immediately if successful
  if quit_on_success then
    vim.schedule(function()
      vim.cmd('quit')
    end)
  end
  
  return true
end

return M
