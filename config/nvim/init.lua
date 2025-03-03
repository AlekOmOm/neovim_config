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
--- Handle command-line arguments


local function handle_args()
  local args = vim.v.argv
  
  -- Check for our custom flags
  for i, arg in ipairs(args) do
    if arg == "-i" and i < #args then
      -- Create directory structure and empty file
      local file_path = vim.fn.fnamemodify(args[i+1], ":p")
      
      -- Check if utils/init_file module is available
      local status_ok, init_file = pcall(require, "utils.init_file")
      if status_ok then
        -- Use the utility function
        if init_file.init_empty_file(file_path) then
          -- Remove the flag and path from args to prevent nvim from trying to handle them
          table.remove(args, i)
          table.remove(args, i)
          -- Add the file path back as a regular argument
          table.insert(args, file_path)
          -- Update argv
          vim.v.argv = args
        end
      else
        -- Fallback if module not available
        local dir = vim.fn.fnamemodify(file_path, ":h")
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
        -- Create empty file
        local file = io.open(file_path, "w")
        if file then
          file:close()
        end
      end
      break
    end
  end
end

-- Run the argument handler
handle_args()





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--- platform mapping  


_G.get_platform_bin = function(server_name)
    local is_windows = vim.fn.has('win32') == 1
    local base_name = server_name
    -- Mapping without extensions
    local mapping = {
        ["pyright"] = "pyright-langserver",
        ["lua_ls"] = "lua-language-server",
        ["tsserver"] = "typescript-language-server", 
        ["html"] = "vscode-html-language-server",
        ["cssls"] = "vscode-css-language-server",
        ["jsonls"] = "vscode-json-language-server",
        ["yamlls"] = "yaml-language-server",
        ["bashls"] = "bash-language-server",
        ["dockerls"] = "docker-langserver",
        ["docker_compose_language_service"] = "docker-compose-langserver",
        ["vimls"] = "vim-language-server",
        ["rust_analyzer"] = "rust-analyzer"
    }
    if mapping[server_name] then
        base_name = mapping[server_name]
    end
    if is_windows then
        return base_name .. ".cmd"
    else
        return base_name
    end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--- Direct LSP configuration

local function setup_lsp()

  -- Platform detection - ensure no .cmd is used on Linux
  local is_windows = vim.fn.has('win32') == 1
  -- Helper function to get correct executable name
  local function get_exe(base_name)
    if is_windows then
      return base_name .. ".cmd"
    else
      return base_name
    end
  end



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


  local server_configs = {
        pyright = {
      	 cmd = { mason_bin .. get_exe("pyright-langserver"), "--stdio" },
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
          cmd = { mason_bin .. get_exe("lua-language-server") }, 
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
          cmd = { mason_bin .. get_exe("typescript-language-server"), "--stdio" },
        },
        html = {
          cmd = { mason_bin .. get_exe("vscode-html-language-server"), "--stdio" }
        },
        cssls = {
          cmd = { mason_bin .. get_exe("vscode-css-language-server"), "--stdio" }
        },
        jsonls = {
          cmd = { mason_bin .. get_exe("vscode-json-language-server"), "--stdio" }
        },
        rust_analyzer = {
          cmd = { mason_bin .. get_exe("rust-analyzer") }
        }
      }

  -- Configure each server
  for server_name, config in pairs(server_configs) do

    -- Check if the executable exists before configuring
    local cmd_path = config.cmd[1]
    if cmd_path:match(".cmd$") and not is_windows then

	-- Remove .cmd suffix on non-Windows platforms
	cmd_path = cmd_path:gsub(".cmd$", "")
    end

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
