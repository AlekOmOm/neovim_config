-- ~/.config/nvim/lua/plugins/lsp/mason.lua

local M = {}

function M.setup()
  local status_ok, mason = pcall(require, "mason")
  if not status_ok then return end
  
  local status_ok_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not status_ok_lspconfig then return end

  -- Mason setup
  mason.setup({
        ui = {
            border = "rounded",
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        },
        max_concurrent_installers = 4,

        download = {
            auto_install = true,
            auto_update = true,
            preferred_method = "curl"
        }
    })
  
  -- Server lists from your existing configuration
  local servers = {
    -- web servers
    "html", "cssls", "ts_ls", "jsonls",
    -- system servers
    "dockerls", "docker_compose_language_service", "bashls",
    -- programming servers
    "pyright", "rust_analyzer", "lua_ls",
    -- config servers
    "yamlls", "vimls"
  }
  
  mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_installation = true,
  })
end

return M
