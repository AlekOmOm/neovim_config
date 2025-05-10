-- ~/test-markdown-preview.lua
-- Minimal configuration test for markdown-preview

-- Clear any existing settings
vim.g.mkdp_auto_start = nil
vim.g.mkdp_auto_close = nil
vim.g.mkdp_theme = nil
vim.g.mkdp_browser = nil
vim.g.mkdp_port = nil
vim.g.mkdp_preview_options = nil

-- Set bare minimum configuration
vim.g.mkdp_browser = "edge"
vim.g.mkdp_theme = "light"
vim.g.mkdp_port = 8888
vim.g.mkdp_preview_options = {
  highlight = {
    theme = "github-light",
    code_block_line_numbers = true
  }
}

-- Print verification
print("=== Markdown Preview Test Configuration ===")
print("Browser: " .. vim.inspect(vim.g.mkdp_browser))
print("Theme: " .. vim.inspect(vim.g.mkdp_theme))
print("Port: " .. vim.inspect(vim.g.mkdp_port))
print("Highlight: " .. vim.inspect(vim.g.mkdp_preview_options.highlight))
print("===========================================")

-- Return true to confirm execution
return true
