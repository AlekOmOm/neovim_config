
local logger = require("utils.logger")
local M = {}

function M.setup()
  -- Create a safe wrapper function for inlay hints
  M.safe_enable_inlay_hints = function(client, bufnr)
    -- Guard: only proceed if client supports inlay hints
    if not client or not client.server_capabilities.inlayHintProvider then
      return
    end

    -- Check if inlay_hint module exists
    if not vim.lsp.inlay_hint then
      return
    end

    -- Safe enablement with error handling
    local status, err = pcall(function()
      -- Neovim 0.10.0 changed the API during development
      -- Try first signature - buffer and boolean
      if type(vim.lsp.inlay_hint.enable) == "function" then
        -- This is the actual fix - make sure we pass a boolean, not a number 
        vim.lsp.inlay_hint.enable(bufnr, true)
      end
    end)

    -- Log any errors that occur
    if not status then
      logger.error("Error enabling inlay hints: " .. tostring(err))
    end
  end

  return M
end

return M
