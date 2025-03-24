-- plugins/lsp/init.lua
local M = {}

-- Define on_attach and capabilities here
M.on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- Notify when an LSP attaches to a buffer
    vim.defer_fn(function()
      vim.notify("LSP " .. client.name .. " attached to buffer " .. bufnr, "info")
    end, 100)  -- Small delay to prevent overlapping

end

-- Add capabilities for auto-completion
M.capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp then
    M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
end

function M.setup()
  -- Set LSP log level for better debugging
  vim.lsp.set_log_level("info")

  -- Load Mason configurations
  local mason_setup_ok, _ = pcall(function()
    require('plugins.lsp.mason').setup()
  end)

  if not mason_setup_ok then
    vim.notify("Failed to setup Mason", "error")
  end

  -- Add a delay to ensure Mason registrations complete
  vim.defer_fn(function()
    -- Setup servers with common configurations
    local servers_setup_ok, servers_setup = pcall(require, 'plugins.lsp.servers')
    if servers_setup_ok then
      servers_setup.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities
      })
    else
      vim.notify("Failed to setup LSP servers", "error")
    end

    -- Setup debug commands
    pcall(function()
      require('plugins.lsp.commands').setup()
    end)

  end, 500)
end

vim.g.lsp_initialized = true

return M
