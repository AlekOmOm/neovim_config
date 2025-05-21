-- lua/plugins/lsp/ts_server_wrapper.lua
--
-- TypeScript LSP server wrapper to fix EventEmitter warnings
--
-- This module injects configuration to increase the EventEmitter default max listeners
-- limit to prevent "MaxListenersExceededWarning" in Node.js TypeScript server.
-- 
-- Available options:
--   config.max_listeners - Number of max listeners (default: 15)
--
local M = {}

function M.setup(config)
  config = config or {}
  local max_listeners = config.max_listeners or 15

  -- Ensure the process.env exists before starting the server
  local env_prepare = string.format([[
  process.setMaxListeners = process.setMaxListeners || function() {};
  require('events').EventEmitter.defaultMaxListeners = %d;
  ]], max_listeners)

  return {
    before_init = function(params)
      -- Inject our env preparation script before server initialization
      params.initializationOptions = params.initializationOptions or {}
      params.initializationOptions.beforeServerStart = env_prepare
      return params
    end
  }
end

return M