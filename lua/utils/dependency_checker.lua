-- lua/utils/dependency_checker.lua
-- Module to check for external Neovim dependencies.

local M = {}

-- Provides path utilities
local paths = require('utils.paths')

---@class DependencyInfo
---@field name string Name of the dependency (e.g., "node", "pyright")
---@field type string Type: "executable", "lsp", "npm_package", "pip_package"
---@field required_by string[] List of plugins/LSPs needing this
---@field check_command? string Command to check presence/version (e.g., "node --version")
---@field min_version? string Minimum version string (e.g., "16.0.0")
---@field installation_method string How it's typically installed: "manual", "mason", "plugin_run_script"
---@field notes? string Additional notes

---@type DependencyInfo[]
M.dependency_inventory = {
  -- Core System Tools
  {
    name = "git",
    type = "executable",
    required_by = {"packer.nvim", "mason.nvim", "nvim-treesitter", "iamcco/markdown-preview.nvim"},
    check_command = "git --version",
    installation_method = "manual",
    notes = "Required by Packer to clone plugins, Mason for some operations, and various plugins."
  },
  {
    name = "node",
    type = "executable",
    required_by = {
      "iamcco/markdown-preview.nvim", "ts_ls", "html-lsp", "cssls-lsp", "jsonls-lsp", 
      "yamlls-lsp", "dockerls-lsp", "bashls-lsp", "eslint-lsp", "vimls-lsp"
    },
    check_command = "node --version",
    min_version = "16.0.0", -- A sensible default, markdown-preview might have specific needs
    installation_method = "manual",
    notes = "Required by markdown-preview.nvim and many LSP servers installed by Mason."
  },
  {
    name = "npm",
    type = "executable",
    required_by = {
      "iamcco/markdown-preview.nvim", "ts_ls", "html-lsp", "cssls-lsp", "jsonls-lsp",
      "yamlls-lsp", "dockerls-lsp", "bashls-lsp", "eslint-lsp", "vimls-lsp"
    },
    check_command = "npm --version",
    installation_method = "manual",
    notes = "Required by markdown-preview.nvim (runs 'npm install') and many LSP servers."
  },
  {
    name = {"python3", "python"}, -- Try python3 first
    type = "executable",
    required_by = {"pyright-lsp"},
    check_command = {"python3 --version", "python --version"},
    min_version = "3.7", -- Pyright generally needs a modern Python 3
    installation_method = "manual",
    notes = "Pyright LSP requires Python. Configuration uses vim.env.NVIM_PYTHON_EXE or defaults."
  },
  {
    name = {"gcc", "clang", "cc"}, -- Try specific compilers first
    type = "executable",
    required_by = {"nvim-telescope/telescope-fzf-native.nvim", "nvim-treesitter"},
    check_command = {"gcc --version", "clang --version", "cc --version"}, -- Corresponding version checks
    installation_method = "manual",
    notes = "C Compiler (like gcc or clang) needed for telescope-fzf-native and nvim-treesitter parsers. Presence is key if version check fails."
  },
  {
    name = "make",
    type = "executable",
    required_by = {"nvim-telescope/telescope-fzf-native.nvim"},
    check_command = "make --version",
    installation_method = "manual",
    notes = "Required to build telescope-fzf-native.nvim."
  },

  -- LSPs (managed by Mason, but their underlying tools might have dependencies)
  -- Mason handles installation, so we primarily note their existence and key deps.
  {
    name = "lua_ls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "Lua Language Server."
  },
  {
    name = "pyright",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "Python LSP. Depends on 'python' executable."
  },
  {
    name = "ts_ls", -- or ts_ls
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "TypeScript/JavaScript LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "html",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "HTML LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "cssls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "CSS LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "jsonls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "JSON LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "rust_analyzer",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "Rust LSP. Depends on Rust (cargo, rustc) toolchain."
  },
  {
    name = "yamlls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "YAML LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "dockerls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "Dockerfile LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "docker_compose_language_service",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "Docker Compose LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "vimls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "VimL LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "bashls",
    type = "lsp",
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "Bash LSP. Depends on 'node' and 'npm'."
  },
  {
    name = "eslint",
    type = "lsp", -- Though more of a linter/formatter used via LSP
    required_by = {"nvim-lspconfig"},
    installation_method = "mason",
    notes = "ESLint. Depends on 'node' and 'npm'. May require project-local eslint."
  },
  {
    name = "markdown_oxide",
    type = "lsp", -- Assumption, could be a general tool
    required_by = {"nvim-lspconfig"}, -- Assumed, as it's in mason ensure_installed
    installation_method = "mason",
    notes = "Markdown tool, likely Rust-based. Mason ensures installation."
  },
  
  -- Specific Plugin Build Steps
  {
    name = "markdown-preview.nvim build",
    type = "plugin_run_script",
    required_by = {"iamcco/markdown-preview.nvim"},
    installation_method = "plugin_run_script", -- via 'cd app && npm install'
    notes = "Depends on 'node' and 'npm' for its `run` step."
  },
  {
    name = "telescope-fzf-native.nvim build",
    type = "plugin_run_script",
    required_by = {"nvim-telescope/telescope-fzf-native.nvim"},
    installation_method = "plugin_run_script", -- via 'make'
    notes = "Depends on 'make' and a C compiler for its `run` step."
  },
  {
    name = "nvim-treesitter parsers",
    type = "plugin_run_script",
    required_by = {"nvim-treesitter/nvim-treesitter"},
    installation_method = "plugin_run_script", -- via TSUpdate
    notes = "Depends on a C compiler and 'git' for its `run` step (TSUpdate)."
  }
}

--- Checks if an executable is available in PATH.
--- @param cmd string The command to check (e.g., "node", "git")
--- @return boolean True if executable, false otherwise
function M.is_executable(cmd)
  if type(cmd) == 'table' then
    for _, c in ipairs(cmd) do
      if vim.fn.executable(c) == 1 then return true end
    end
    return false
  else
    return vim.fn.executable(cmd) == 1
  end
end

--- Parses a version string (e.g., "v1.2.3", "1.2.3") into major, minor, patch.
--- @param version_str string
--- @return table? {major: number, minor: number, patch: number} or nil
local function parse_version(version_str)
  if not version_str or type(version_str) ~= 'string' then return nil end
  local major, minor, patch = version_str:match("[vV]?(\d+)\.(\d+)\.(\d+)")
  if major then
    return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
  end
  major, minor = version_str:match("[vV]?(\d+)\.(\d+)")
  if major then
    return { major = tonumber(major), minor = tonumber(minor), patch = 0 }
  end
  major = version_str:match("[vV]?(\d+)")
  if major then
    return { major = tonumber(major), minor = 0, patch = 0 }
  end
  return nil
end

--- Compares two parsed version tables.
--- @param v1 table {major, minor, patch}
--- @param v2 table {major, minor, patch}
--- @return number 0 if v1 == v2, 1 if v1 > v2, -1 if v1 < v2
local function compare_versions(v1, v2)
  if v1.major > v2.major then return 1
  elseif v1.major < v2.major then return -1
  else -- major versions are equal
    if v1.minor > v2.minor then return 1
    elseif v1.minor < v2.minor then return -1
    else -- minor versions are equal
      if v1.patch > v2.patch then return 1
      elseif v1.patch < v2.patch then return -1
      else return 0 -- versions are equal
      end
    end
  end
end

--- Gets the version of an executable by running its version command.
--- @param version_cmd string The command to get version (e.g., "node --version")
--- @return string? The raw version string output, or nil if error/not found
function M.get_executable_version_raw(version_cmd)
  if not version_cmd then return nil end
  local stderr_redirect = vim.fn.has('win32') == 1 and "2>nul" or "2>/dev/null"
  local cmd_to_run = version_cmd .. " " .. stderr_redirect
  
  local handle = io.popen(cmd_to_run)
  if handle then
    local output = handle:read("*a")
    handle:close()
    if output and #output > 0 then
      return vim.trim(output)
    end
  end
  return nil
end

--- Checks a single executable dependency.
--- @param dep DependencyInfo
--- @return table? {name: string, status: "ok"|"missing"|"version_low"|"error", message: string, found_version?: string}
function M.check_executable_dependency(dep)
  local result = { name = type(dep.name) == 'table' and table.concat(dep.name, "/") or dep.name, status = "error", message = "Unknown error during check." }
  local found_exe_name = nil
  local version_cmd_to_use = nil

  local exe_names = type(dep.name) == 'table' and dep.name or {dep.name}
  local version_cmds = type(dep.check_command) == 'table' and dep.check_command or (dep.check_command and {dep.check_command} or nil)

  for i, exe_name_candidate in ipairs(exe_names) do
    if M.is_executable(exe_name_candidate) then
      found_exe_name = exe_name_candidate
      if version_cmds and version_cmds[i] then
        version_cmd_to_use = version_cmds[i]
      elseif version_cmds and #version_cmds == 1 then -- If only one version command for multiple names
        version_cmd_to_use = version_cmds[1]
      else -- No specific version command for this found exe, or no version_cmds at all
        version_cmd_to_use = nil 
      end
      break
    end
  end

  if not found_exe_name then
    result.status = "missing"
    result.message = "'" .. result.name .. "' executable not found in PATH."
    return result
  end
  
  -- Update result name to the specific executable that was found if it was a list
  result.name = found_exe_name

  if not version_cmd_to_use then -- Only presence check was intended or possible
    result.status = "ok"
    result.message = "'" .. found_exe_name .. "' executable found."
    return result
  end

  local raw_version_output = M.get_executable_version_raw(version_cmd_to_use)
  if not raw_version_output then
    result.status = "error"
    result.message = "Found '" .. found_exe_name .. "' but failed to get version using: " .. version_cmd_to_use
    return result
  end
  result.found_version = raw_version_output

  if not dep.min_version then -- Presence and version obtainable, but no min_version specified
    result.status = "ok"
    result.message = "'" .. found_exe_name .. "' found. Version: " .. raw_version_output
    return result
  end

  local current_version = parse_version(raw_version_output)
  local min_version_parsed = parse_version(dep.min_version)

  if not current_version then
    result.status = "error"
    result.message = "Found '" .. found_exe_name .. "' (reported: "..raw_version_output..") but could not parse its version."
    return result
  end
  if not min_version_parsed then
    result.status = "error" -- Should not happen if inventory is correct
    result.message = "Could not parse minimum version '" .. dep.min_version .. "' for '" .. found_exe_name .. "'."
    return result
  end

  if compare_versions(current_version, min_version_parsed) >= 0 then
    result.status = "ok"
    result.message = "'" .. found_exe_name .. "' found. Version: " .. raw_version_output .. " (meets minimum " .. dep.min_version .. ")"
  else
    result.status = "version_low"
    result.message = "'" .. found_exe_name .. "' found. Version: " .. raw_version_output .. " (BELOW minimum " .. dep.min_version .. ")"
  end
  return result
end

---@return table[] List of check result tables
function M.verify_all_dependencies()
  local results = {}
  local executable_check_results = {} -- Store results of executable checks

  -- First pass: check all executables and store their results
  for _, dep_info in ipairs(M.dependency_inventory) do
    if dep_info.type == "executable" then
      local check_res = M.check_executable_dependency(dep_info)
      table.insert(results, check_res)
      executable_check_results[dep_info.name] = check_res -- Store by original name (string or first in table)
      if type(dep_info.name) == 'table' then -- also store by specific found name if different
        executable_check_results[check_res.name] = check_res
      end
    end
  end

  -- Second pass: process LSPs and other types, referring to executable_check_results
  for _, dep_info in ipairs(M.dependency_inventory) do
    if dep_info.type == "lsp" then
      local lsp_result = {
        name = dep_info.name,
        status = "info", 
        message = "LSP '" .. dep_info.name .. "' installation is managed by Mason."
      }
      local underlying_deps_issues = {}

      -- Check for known underlying executable dependencies
      if dep_info.name == "pyright" then
        local python_res = executable_check_results["python3"] or executable_check_results["python"] -- Check common names
        if python_res and python_res.status ~= "ok" then
          table.insert(underlying_deps_issues, "Python ('" .. python_res.name .. "'): " .. python_res.message)
        end
      elseif dep_info.name == "ts_ls" or dep_info.name == "html" or dep_info.name == "cssls" or dep_info.name == "jsonls" or dep_info.name == "yamlls" or dep_info.name == "dockerls" or dep_info.name == "docker_compose_language_service" or dep_info.name == "vimls" or dep_info.name == "bashls" or dep_info.name == "eslint" then
        local node_res = executable_check_results["node"]
        if node_res and node_res.status ~= "ok" then
          table.insert(underlying_deps_issues, "Node.js ('node'): " .. node_res.message)
        end
        local npm_res = executable_check_results["npm"]
        if npm_res and npm_res.status ~= "ok" then
         table.insert(underlying_deps_issues, "NPM ('npm'): " .. npm_res.message)
        end
      elseif dep_info.name == "rust_analyzer" then
        -- Assuming Rust toolchain (rustc, cargo) is checked by a generic "rust" or handled by Mason directly.
        -- For now, no specific executable check here unless we add a "rust" entry to inventory.
      elseif dep_info.name == "markdown_oxide" then
        -- similar to rust_analyzer, assuming Mason handles or needs a "rust" check
      end
      
      if #underlying_deps_issues > 0 then
        lsp_result.message = lsp_result.message .. " However, it has underlying dependency issues: " .. table.concat(underlying_deps_issues, "; ")
        -- Optionally change status if critical underlying deps are missing
        -- lsp_result.status = "warning" 
      else
        lsp_result.message = lsp_result.message .. " Ensure Mason has installed it successfully."
      end
      table.insert(results, lsp_result)

    elseif dep_info.type == "plugin_run_script" then
      local script_result = {
        name = dep_info.name,
        status = "info",
        message = "Plugin script '" .. dep_info.name .. "' relies on its own dependencies (e.g., node, make, cc) being present and checked separately."
      }
      -- Example: Check if 'make' is ok for telescope-fzf-native build
      if dep_info.name == "telescope-fzf-native.nvim build" then
        local make_res = executable_check_results["make"]
        local cc_res = executable_check_results["gcc"] or executable_check_results["clang"] or executable_check_results["cc"]
        if (make_res and make_res.status ~= "ok") or (cc_res and cc_res.status ~= "ok") then
          script_result.message = script_result.message .. " Issues found with: "
          if make_res and make_res.status ~= "ok" then script_result.message = script_result.message .. "make (" .. make_res.message .. ") " end
          if cc_res and cc_res.status ~= "ok" then script_result.message = script_result.message .. "C compiler (" .. cc_res.message .. ")" end
        end
      end
      -- Similar checks can be added for other build scripts
      table.insert(results, script_result)

    elseif dep_info.type ~= "executable" then -- Executables already processed
      table.insert(results, {
        name = dep_info.name,
        status = "skipped",
        message = "Checker for type '" .. dep_info.type .. "' not yet implemented or handled in a different pass."
      })
    end
  end
  return results
end

return M 