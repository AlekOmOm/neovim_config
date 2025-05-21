
local logger = require("utils.logger")
local M = {}

function M.setup()
  -- Create a safe wrapper function for inlay hints
  M.safe_enable_inlay_hints = function(client, bufnr)

    if not client or not client.server_capabilities.inlayHintProvider then
      return
    end

    -- Check if inlay_hint module exists
    if not vim.lsp.inlay_hint then
      return
    end

    -- Safe enablement with error handling
    local status, err = pcall(function()
      if type(vim.lsp.inlay_hint.enable) == "function" then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr  })
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
