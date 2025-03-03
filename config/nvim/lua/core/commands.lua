-- ~/.config/nvim/lua/core/commands.lua

-- Custom commands
local function setup_commands()
  -- Command to create a new file and its directory structure
  vim.api.nvim_create_user_command('Touch', function(opts)
    local file_path = opts.args
    
    -- Expand to full path
    file_path = vim.fn.expand(file_path)
    
    -- Get the directory from the file path
    local dir = vim.fn.fnamemodify(file_path, ":h")
    
    -- Create directory structure if it doesn't exist
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify("Failed to create directory: " .. dir, 0) -- ERROR only
        return
      end
    end
    
    -- Create the file if it doesn't exist
    if vim.fn.filereadable(file_path) == 0 then
      local file = io.open(file_path, "w")
      if not file then
        vim.notify("Failed to create file: " .. file_path, 0) -- ERROR only
        return
      end
      file:close()
    end
    
    -- Quit Neovim after successful operation
    vim.cmd('quit')
    
  end, {
    nargs = 1,
    complete = 'file',
    desc = 'Create a new file and necessary directories'
  })
end

setup_commands()

-- Return the module
return {
  setup = setup_commands
}
