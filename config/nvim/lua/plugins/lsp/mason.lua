-- ~/.config/nvim/lua/plugins/lsp/mason.lua

local M = {}

function M.setup()
  local status_ok, mason = pcall(require, "mason")
  if not status_ok then 
    vim.notify("mason not found!", "error")
    return 
  end

  local status_ok_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not status_ok_lspconfig then 
    vim.notify("mason-lspconfig not found!", "error")
    return 
  end

  -- Detect platform
  local is_windows = vim.fn.has('win32') == 1

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
    -- Important for Windows: specify the correct path behavior
    install_root_dir = vim.fn.stdpath("data") .. "/mason",
    PATH = "prepend"
  })

  -- Server lists - note the correct names
  local servers = {
    -- web servers
    "html", "cssls", "tsserver", "jsonls",
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

  -- Print debug info about Mason installation
  vim.defer_fn(function()
    vim.notify("Mason path: " .. vim.fn.stdpath("data") .. "/mason/bin", "info")
    if is_windows then
      vim.notify("Windows platform detected - using .cmd extensions", "info")
    end
  end, 1000)
end

return M
