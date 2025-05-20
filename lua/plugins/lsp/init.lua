-- ~/.config/nvim/lua/plugins/lsp/init.lua
-- minimal lsp bootstrap: one file, no external “servers.lua” needed
local M = {}

local inlay = require('plugins.lsp.inlay_hints').setup()

-- ---------------------------------------------------------------------------
-- common on_attach
-- ---------------------------------------------------------------------------
M.on_attach = function(client, bufnr)
  local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, noremap = true, silent = true }) end

  -- basic nav / help
  map("gd", vim.lsp.buf.definition)
  map("K",  vim.lsp.buf.hover)
  map("gi", vim.lsp.buf.implementation)
  map("<c-k>",     vim.lsp.buf.signature_help)
  map("<leader>D", vim.lsp.buf.type_definition)
  map("<leader>ca",vim.lsp.buf.code_action)
  map("gr",         vim.lsp.buf.references)
  map("<leader>f",  function() vim.lsp.buf.format { async = true } end)

  inlay.safe_enable_inlay_hints(client, bufnr)

end

-- ---------------------------------------------------------------------------
-- capabilities (cmp aware)
-- ---------------------------------------------------------------------------
M.capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  (pcall(require, "cmp_nvim_lsp") and require("cmp_nvim_lsp").default_capabilities() or {})
)

-- ---------------------------------------------------------------------------
-- top-level setup
-- ---------------------------------------------------------------------------
function M.setup()

   require('plugins.lsp.mason').setup {
    on_attach    = M.on_attach,
    capabilities = M.capabilities,
  }

  -- extra user commands / debug helpers (optional)
  pcall(function() require("plugins.lsp.commands").setup() end)
  pcall(function() require("plugins.lsp.debug").setup()    end)
  pcall(function() require("plugins.lsp.platform_fix").setup() end) -- if present
end

return M

