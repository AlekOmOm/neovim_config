-- ~/.config/nvim/lua/plugins/lsp/mason.lua

local M = {}
local paths = require("utils.paths")

-- pass { on_attach = …, capabilities = … } from your main lsp setup
function M.setup(opts)
  -- safety checks ------------------------------------------------------------
  local ok, mason = pcall(require, "mason");              if not ok then vim.notify("mason not found!", "error"); return end
  ok, mason_lspconfig  = pcall(require, "mason-lspconfig"); if not ok then vim.notify("mason-lspconfig not found!", "error"); return end
  ok, lspconfig        = pcall(require, "lspconfig");       if not ok then vim.notify("lspconfig not found!", "error");       return end

  -- mason core ---------------------------------------------------------------
  mason.setup({
    ui = {
      border = "rounded",
      icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
    },
    max_concurrent_installers = 4,
    install_root_dir = paths.join(vim.fn.stdpath("data"), "mason"),
    PATH = "prepend",
  })

  -- servers to ensure --------------------------------------------------------
  local ensure_installed = {
    -- web
    "html", "cssls", "ts_ls", "jsonls",
    -- system
    "dockerls", "docker_compose_language_service", "bashls",
    -- langs
    "pyright", "rust_analyzer", "lua_ls",
    -- configs
    "yamlls", "vimls",
    -- misc
    "markdown_oxide",
  }

  -- per-server tweaks --------------------------------------------------------
  local server_configs = {
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace   = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
          telemetry   = { enable = false },
        },
      },
    },

    pyright = {
      settings = {
        python = {
          analysis = {
            typeCheckingMode    = "basic",
            autoSearchPaths     = true,
            diagnosticMode      = "workspace",
            useLibraryCodeForTypes = true,
          },
        },
      },
    },

    rust_analyzer = {
      settings = { ["rust-analyzer"] = { checkOnSave = { command = "clippy" } } },
    },

    markdown_oxide = {
      filetypes = { "markdown" },
      root_dir  = lspconfig.util.root_pattern(".git", ".obsidian", ".moxide.toml"),
      single_file_support = true,
    },

    ts_ls = { -- typescript-language-server :contentReference[oaicite:0]{index=0}
      settings = {
        -- put extra ts settings here if you need them
      },
    },
  }

  -- mason-lspconfig glue -----------------------------------------------------
  mason_lspconfig.setup({
    ensure_installed      = ensure_installed,
    automatic_installation = true,

    handlers = {
      function(server)
        lspconfig[server].setup({
          capabilities = opts.capabilities,
          on_attach    = opts.on_attach,
        })
      end,
    },
  })

  -- apply per-server overrides ----------------------------------------------
  for name, cfg in pairs(server_configs) do
    lspconfig[name].setup(vim.tbl_deep_extend("force", {
      capabilities = opts.capabilities,
      on_attach    = opts.on_attach,
    }, cfg))
  end

  -- optional debug -----------------------------------------------------------
  vim.defer_fn(function()
    vim.notify("mason initialised ➜ " .. paths.join(vim.fn.stdpath("data"), "mason"), "info")
  end, 1000)
end

return M

