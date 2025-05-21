-- after/plugin/fix_copilot_deprecation.lua
--
-- Fix for Copilot deprecation warning: vim.lsp.start_client() -> vim.lsp.start()
-- This patch will be applied after the Copilot plugin loads

-- Check if _copilot module exists and monkey-patch its start function
local has_copilot, _copilot = pcall(require, "_copilot")

if has_copilot and _copilot then
  -- Store original start function
  local original_start = _copilot.start

  -- Replace with our patched version
  _copilot.start = function(...)
    -- Check if vim.lsp.start is available (Neovim 0.8+)
    if vim.lsp.start then
      -- Patch for Neovim 0.8+
      local args = {...}

      -- The first argument to the start function is the LSP client config
      if args and args[1] and type(args[1]) == "table" then
        -- Use vim.lsp.start instead of vim.lsp.start_client
        local client_id = vim.lsp.start(args[1])
        return client_id
      end
    end

    -- Fallback: call original function for older Neovim versions
    return original_start(...)
  end

  vim.notify("Applied patch for Copilot deprecation warnings", vim.log.levels.DEBUG)
end