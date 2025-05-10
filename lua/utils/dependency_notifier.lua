-- lua/utils/dependency_notifier.lua
-- Module to notify user about missing or problematic external dependencies.

local M = {}

local checker = require('utils.dependency_checker')

--- Formats and displays notifications for dependency check results.
function M.notify_dependency_issues()
  local results = checker.verify_all_dependencies()
  local issues_found = false
  local critical_issues = 0
  local warning_issues = 0

  local notification_messages = {
    critical = {title = "Critical Dependencies Missing!", items = {}},
    warning = {title = "Dependency Warnings", items = {}},
    info = {title = "Dependency Info", items = {}} -- For LSPs managed by Mason etc.
  }

  for _, res in ipairs(results) do
    if res.status == "missing" then
      table.insert(notification_messages.critical.items, "- " .. res.name .. ": MISSING. " .. res.message .. " Please install it.")
      critical_issues = critical_issues + 1
      issues_found = true
    elseif res.status == "version_low" then
      table.insert(notification_messages.warning.items, "- " .. res.name .. ": Version LOW. " .. res.message .. " Consider upgrading.")
      warning_issues = warning_issues + 1
      issues_found = true
    elseif res.status == "error" then -- Error during check, treat as warning for notification
      table.insert(notification_messages.warning.items, "- " .. res.name .. ": Check ERROR. " .. res.message)
      warning_issues = warning_issues + 1
      issues_found = true
    elseif res.status == "info" then
      -- Only add LSP/script info if there are no critical/warning issues, to avoid clutter
      -- Or, always add them if desired.
      -- For now, let's add them to a separate info notification if no other major issues.
      table.insert(notification_messages.info.items, "- " .. res.name .. ": " .. res.message)
    end
    -- "ok" and "skipped" statuses are not actively notified to reduce noise
  end

  if critical_issues > 0 then
    local final_message = table.concat(notification_messages.critical.items, "\n")
    vim.notify(final_message, vim.log.levels.ERROR, { title = notification_messages.critical.title })
  end

  if warning_issues > 0 then
    local final_message = table.concat(notification_messages.warning.items, "\n")
    vim.notify(final_message, vim.log.levels.WARN, { title = notification_messages.warning.title })
  end

  -- Optional: Show info messages if no errors or warnings, or always show them
  if critical_issues == 0 and warning_issues == 0 and #notification_messages.info.items > 0 then
     local final_message = table.concat(notification_messages.info.items, "\n")
     vim.notify(final_message, vim.log.levels.INFO, { title = notification_messages.info.title })
  elseif #notification_messages.info.items > 0 and (critical_issues > 0 or warning_issues > 0) then
    -- If there were errors/warnings, perhaps a less prominent way to show info, or a combined notification.
    -- For now, we'll log it if other issues are present.
    vim.print("Dependency Info Log (see also notifications):")
    for _, item_msg in ipairs(notification_messages.info.items) do
        vim.print(item_msg)
    end
  end

  if not issues_found then
    vim.notify("All critical external dependencies seem to be configured correctly.", vim.log.levels.INFO, { title = "Dependency Check OK" })
  end
end

-- Example of how to call it (e.g., on Neovim startup after plugins are loaded)
-- M.notify_dependency_issues()

return M 