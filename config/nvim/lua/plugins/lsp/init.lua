-- plugins/lsp/init.lua
local M = {}

-- Define on_attach and capabilities here
M.on_attach = function(client, bufnr)
  -- Your keymaps and setup
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp then
    M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
end

function M.setup()
  -- Load Mason configurations
  require('plugins.lsp.mason').setup()
  
  -- Setup servers with common configurations
  require('plugins.lsp.servers').setup({
    on_attach = M.on_attach,
    capabilities = M.capabilities
  })
end

return M
