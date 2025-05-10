-- lua/utils/analyze_profile.lua

-- Explicitly add CWD's /lua to package.path for nvim -l context
local cwd = vim.loop.cwd()
if cwd then
    vim.notify("analyze_profile.lua: Current CWD: " .. cwd, vim.log.levels.INFO)
    local lua_path_addition = cwd .. "/lua/?.lua;" .. cwd .. "/lua/?/init.lua"
    -- Normalize path separators for package.path (Lua likes /)
    lua_path_addition = lua_path_addition:gsub("[\\/]", "/")
    package.path = package.path .. ";" .. lua_path_addition
    vim.notify("analyze_profile.lua: Added to package.path: " .. lua_path_addition, vim.log.levels.INFO)
else
    vim.notify("analyze_profile.lua: Warning - Could not get CWD. utils.paths might not be found.", vim.log.levels.WARN)
end

-- When running with nvim -l, this script expects to be run from the Neovim config root directory.
-- utils.paths should be findable via relative paths if CWD is config root.
-- The problematic <sfile> logic that was here has been removed.

local M = {}

--- Parses a Neovim profile log file to extract script loading times.
-- @param log_file_path string: The absolute path to the profile.log file.
-- @return table|nil: A table of script performance data or nil on error.
-- Each entry in the table: { path = "/path/to/script.lua", time = 0.123456 }
function M.parse_profile_log(log_file_path)
    vim.notify(string.format("analyze_profile.lua: M.parse_profile_log called with: %s", log_file_path), vim.log.levels.INFO)
    local file = io.open(log_file_path, "r")
    if not file then
        vim.notify("Error: Could not open profile log file: " .. log_file_path, vim.log.levels.ERROR)
        return nil
    end

    local performances = {}
    local current_script_path = nil

    for line in file:lines() do
        -- Match SCRIPT line
        -- Example: SCRIPT  C:\Users\Bruger\AppData\Local\nvim-data\site\pack\packer\start\vim-fugitive\ftdetect\fugitive.vim
        local script_path_match = line:match("^SCRIPT%s+(.+)$")
        if script_path_match then
            current_script_path = script_path_match:match("^%s*(.-)%s*$") -- Trim whitespace
            -- vim.notify("Found script: " .. current_script_path) -- Debug
        end

        -- Match Total time line (usually 2 lines after SCRIPT)
        -- Example: Total time:   0.000045
        if current_script_path then -- Only look for time if we have a current script
            local total_time_match = line:match("^Total time:%s+([%d%.]+)$")
            if total_time_match then
                local time_val = tonumber(total_time_match)
                if time_val then
                    table.insert(performances, { path = current_script_path, time = time_val })
                    -- vim.notify(string.format("Path: %s, Time: %.6f", current_script_path, time_val)) -- Debug
                    current_script_path = nil -- Reset for the next SCRIPT block
                else
                    vim.notify("Warning: Could not convert time to number for: " .. current_script_path .. " | Line: " .. line, vim.log.levels.WARN)
                end
            end
        end
    end

    file:close()

    if #performances == 0 then
        vim.notify("Warning: No script performance data extracted from " .. log_file_path, vim.log.levels.WARN)
        return {}
    end

    return performances
end

--- Analyzes and prints a report of script loading times.
-- @param performances table: A table of script performance data from parse_profile_log.
-- @param num_top_scripts integer (optional): Number of slowest scripts to display (default 15).
function M.analyze_and_report(performances, num_top_scripts)
    if not performances or #performances == 0 then
        print("No performance data to analyze.")
        return
    end

    num_top_scripts = num_top_scripts or 15

    -- Sort by time, descending
    table.sort(performances, function(a, b) return a.time > b.time end)

    local total_startup_time = 0
    for _, data in ipairs(performances) do
        total_startup_time = total_startup_time + data.time
    end

    print(string.format("\n--- Neovim Startup Profile Analysis ---"))
    print(string.format("Total profiled time for %d scripts: %.6f seconds", #performances, total_startup_time))
    print(string.format("Showing top %d slowest scripts:\n", math.min(num_top_scripts, #performances)))

    print(string.format("%-10s | %-15s | %-10s | %s", "Time (s)", "% of Total", "Count", "Script Path"))
    print(string.rep("-", 80))

    for i = 1, math.min(num_top_scripts, #performances) do
        local data = performances[i]
        local percentage = (data.time / total_startup_time) * 100
        -- For now, count is 1 as we are not aggregating identical script paths if sourced multiple times yet
        -- This could be enhanced if profile logs show multiple entries for the same script distinctly.
        print(string.format("%.6f | %14.2f%% | %-10d | %s", data.time, percentage, 1, data.path))
    end

    -- Suggestion: Identify potential plugin files (heuristic)
    local plugin_candidates = {}
    for _, data in ipairs(performances) do
        if data.path:match("[pP]lugins?/") or data.path:match("/pack/.*/start/.+") or data.path:match("[lL]ua/.+[.]lua") then
            if data.time > 0.01 then -- Arbitrary threshold for suggestion, e.g., > 10ms
                 table.insert(plugin_candidates, data)
            end
        end
    end

    if #plugin_candidates > 0 then
        print("\n--- Potential Plugins/Modules for Lazy-Loading Consideration (if not already): ---")
        -- Sort candidates by time as well for this list
        table.sort(plugin_candidates, function(a,b) return a.time > b.time end)
        for i=1, math.min(10, #plugin_candidates) do -- Show top 10 of these candidates
            local data = plugin_candidates[i]
            print(string.format("%.6f s - %s", data.time, data.path))
        end
    end
    print("\nNote: 'Total profiled time' is the sum of times for SCRIPT blocks found in the log.")
    print("This may differ slightly from the VimEnter calculated total startup time.")
end

-- Main execution when script is run directly (e.g., nvim -l lua/utils/analyze_profile.lua path/to/your/profile.log)
if not pcall(debug.getlocal, 4, 1) then -- Check if being run as main script
    vim.notify("analyze_profile.lua: Main execution block started.", vim.log.levels.INFO)

    local initial_arg_from_varargs = select(1, ...)
    vim.notify(string.format("analyze_profile.lua: Initial arg from ... (varargs): %s (type: %s)", tostring(initial_arg_from_varargs), type(initial_arg_from_varargs)), vim.log.levels.INFO)

    local initial_arg_from_argv = nil
    if vim.v.argv and #vim.v.argv > 0 then
        vim.notify("analyze_profile.lua: vim.v.argv content: " .. vim.inspect(vim.v.argv), vim.log.levels.INFO)
        -- Look for '--' to find the start of script arguments
        local script_args_start_index = -1
        for i, arg_val in ipairs(vim.v.argv) do
            if arg_val == "--" then
                script_args_start_index = i + 1
                break
            end
        end

        if script_args_start_index > 0 and script_args_start_index <= #vim.v.argv then
            initial_arg_from_argv = vim.v.argv[script_args_start_index]
            vim.notify("analyze_profile.lua: Found script argument after '--' in vim.v.argv: " .. initial_arg_from_argv, vim.log.levels.INFO)
        else
            vim.notify("analyze_profile.lua: '--' marker not found or no args after it in vim.v.argv. Arg count: " .. tostring(#vim.v.argv) .. ". Will rely on fallback if varargs also nil.", vim.log.levels.INFO)
            -- Fallback heuristic if "--" is not present (e.g. nvim -l script arg, though not recommended)
            if #vim.v.argv == 1 and vim.v.argv[1]:match("[^%-].*%.log$") then
                 initial_arg_from_argv = vim.v.argv[1]
                 vim.notify("analyze_profile.lua: Used fallback heuristic for vim.v.argv (single log-like arg): " .. initial_arg_from_argv, vim.log.levels.INFO)
            end
        end
    end
    vim.notify(string.format("analyze_profile.lua: Initial arg from vim.v.argv (refined): %s (type: %s)", tostring(initial_arg_from_argv), type(initial_arg_from_argv)), vim.log.levels.INFO)

    local initial_arg = initial_arg_from_varargs or initial_arg_from_argv
    vim.notify(string.format("analyze_profile.lua: Chosen initial_arg: %s (type: %s)", tostring(initial_arg), type(initial_arg)), vim.log.levels.INFO)

    local log_file_to_parse

    if initial_arg and type(initial_arg) == "string" and #initial_arg > 0 then
        -- Try to make it an absolute path. If it's already absolute, fnamemodify should handle it.
        -- If it's relative, it's relative to Neovim's CWD when launched with -l.
        log_file_to_parse = vim.fn.fnamemodify(initial_arg, ":p")
        vim.notify("analyze_profile.lua: Using explicit argument, resolved to absolute path: " .. log_file_to_parse, vim.log.levels.INFO)
    else
        vim.notify("analyze_profile.lua: No valid explicit argument or argument is not a string. Attempting fallback to latest log.", vim.log.levels.INFO)
        
        local paths_util_ok, paths_util = pcall(require, "utils.paths")
        if not paths_util_ok or not paths_util then
            local err_msg = "analyze_profile.lua: Error - Failed to require 'utils.paths'. Ensure you are running nvim -l from your config root, and utils/paths.lua exists there (e.g., lua/utils/paths.lua)."
            print(err_msg)
            vim.notify(err_msg, vim.log.levels.ERROR)
            return
        end

        local current_working_dir = vim.loop.cwd()
        vim.notify("analyze_profile.lua: Fallback - Current working directory: " .. current_working_dir, vim.log.levels.INFO)
        
        local log_dir = paths_util.join(current_working_dir, "logs", "profile-logs")
        vim.notify("analyze_profile.lua: Fallback - Looking for logs in: " .. log_dir, vim.log.levels.INFO)
        local files = vim.fn.glob(paths_util.join(log_dir, "profile_*.log"), false, true)

        if files and #files > 0 then
            table.sort(files, function(a,b) return a > b end) -- Sort descending by name to get latest
            log_file_to_parse = files[1] -- glob should return absolute paths
            vim.notify("analyze_profile.lua: Fallback - Using latest log found: " .. log_file_to_parse, vim.log.levels.INFO)
        else
            local err_msg_print = "Error: No profile log file specified and no logs found in " .. log_dir .. "\\nUsage: nvim -l lua/utils/analyze_profile.lua <path_to_profile_log>"
            local err_msg_notify = "analyze_profile.lua: Error - No profile log file specified and no logs found in " .. log_dir
            print(err_msg_print)
            vim.notify(err_msg_notify, vim.log.levels.ERROR)
            return
        end
    end

    if not log_file_to_parse then
        local err_msg = "analyze_profile.lua: Error - log_file_to_parse is inexplicably nil after trying to determine it."
        print(err_msg)
        vim.notify(err_msg, vim.log.levels.ERROR)
        return
    end

    vim.notify("analyze_profile.lua: Attempting to parse: " .. log_file_to_parse, vim.log.levels.INFO)
    local performance_data = M.parse_profile_log(log_file_to_parse)

    if performance_data then
        vim.notify("analyze_profile.lua: Performance data received from parse_profile_log. Analyzing and reporting.", vim.log.levels.INFO)
        M.analyze_and_report(performance_data)
    else
        vim.notify("analyze_profile.lua: M.parse_profile_log returned nil or empty for: " .. log_file_to_parse .. ". Check previous notifications from parse_profile_log.", vim.log.levels.WARN)
    end
    vim.notify("analyze_profile.lua: Main execution block finished.", vim.log.levels.INFO)
end

return M 