-- ~/.config/nvim/lua/utils/init_file.lua

local M = {}

function M.init_empty_file(file_path)
  -- Get the directory from the file path
  local dir = vim.fn.fnamemodify(file_path, ":h")
  
  -- Create directory structure if it doesn't exist
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
    vim.notify("Created directory: " .. dir, "info")
  end
  
  -- Create the file if it doesn't exist
  if vim.fn.filereadable(file_path) == 0 then
    local file = io.open(file_path, "w")
    if file then
      file:close()
      vim.notify("Created empty file: " .. file_path, "info")
    else
      vim.notify("Failed to create file: " .. file_path, "error")
      return false
    end
  end
  
  return true
end

return M
