-- ~/.config/nvim/init.lua

--- @type table
vim = vim

-- Bootstrap packer first
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        print "Installing packer... Please restart Neovim after installation."
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Check if packer is available
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Initialize packer
packer.startup(function(use)
    use 'wbthomason/packer.nvim'

    if packer_bootstrap then
        packer.sync()
        return
    end
end)

-- Only load configurations if not bootstrapping
if not packer_bootstrap then

    require('core')
    require('plugins')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--- Direct LSP configuration

local function setup_lsp()
  -- Check if necessary plugins are available
  local has_lspconfig, lspconfig = pcall(require, "lspconfig")
  if not has_lspconfig then
    print("nvim-lspconfig not found. LSP functionality disabled.")
    return
  end

  local has_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if has_cmp_lsp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  -- Basic keymappings for LSP
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

    print("LSP attached: " .. client.name)
  end

  -- Get path to Mason bin directory with executable language servers
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
  -- Define commands and executables for servers on Windows

  local cmd_ending = vim.fn.has("win32") == 1 and ".cmd" or ""

  local server_configs = {
        pyright = {
          cmd = { mason_bin .. "pyright-langserver"+cmd_ending, "--stdio" },
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true
              }
            }
          }
        },
        lua_ls = {
          cmd = { mason_bin .. "lua-language-server"+cmd_ending },
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false }
            }
          }
        },
        ts_ls = {
          cmd = { mason_bin .. "typescript-language-server"+cmd_ending", "--stdio" }
        },
        html = {
          cmd = { mason_bin .. "vscode-html-language-server"+cmd_ending, "--stdio" }
        },
        cssls = {
          cmd = { mason_bin .. "vscode-css-language-server"+cmd_ending, "--stdio" }
        },
        jsonls = {
          cmd = { mason_bin .. "vscode-json-language-server"+cmd_ending, "--stdio" }
        },
        rust_analyzer = {
          cmd = { mason_bin .. "rust-analyzer"+cmd_ending }
        }
      },
  }

  -- Configure each server
  for server_name, config in pairs(server_configs) do

    -- Check if the executable exists before configuring
    local cmd_path = config.cmd[1]
    local exists = vim.fn.filereadable(cmd_path) == 1

    if exists then
      -- Add common options to each server
      config.on_attach = on_attach
      config.capabilities = capabilities
      config.flags = { debounce_text_changes = 150 }

      -- Setup the server
      lspconfig[server_name].setup(config)
      -- print("Configured LSP: " .. server_name .. " with: " .. cmd_path)
    else
      print("LSP executable not found: " .. cmd_path)
    end
  end
  -- Create simple diagnostic commands
  vim.api.nvim_create_user_command('LspInfo', function()
    -- deprecated: local clients = vim.lsp.get_active_clients()
    local clients = vim.lsp.get_clients() or {}
    clients = vim.tbl_filter(function(client)
      return client.name ~= "null-ls"
    end, clients)
    if #clients == 0 then
      print("No active LSP clients")
      return
    end

    for _, client in ipairs(clients) do
      print(string.format(
        "• %s (id: %d) - cmd: %s",
        client.name,
        client.id,
        vim.inspect(client.config.cmd)
      ))
    end
  end, {})
  vim.api.nvim_create_user_command('LspLog', function()
    local log_path = vim.lsp.get_log_path()
    print("Opening LSP log: " .. log_path)
    vim.cmd('split ' .. log_path)
  end, {})
end

-- Set higher log level for debugging
vim.lsp.set_log_level("debug")

-- Run the direct LSP setup function
setup_lsp()

-- Print status message
-- print("Direct LSP configuration loaded. Try opening a Python file and check with :LspInfo")
