local function get_default_branch()
  local handle = io.popen("git branch -l master main | tr -d ' \n\t'")
  if not handle then return "" end
  local output = handle:read("*a")
  handle:close()
  if output:find("main") then
    return "origin/main"
  else
    return "origin/master"  -- fallback default
  end
end

local function git_diff_from(branch)
  branch = branch ~= "" and branch or get_default_branch()
  local handle = io.popen("git merge-base HEAD " .. branch)
  if not handle then
    vim.notify("Failed to run git merge-base", vim.log.levels.ERROR)
    return
  end
  local base = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  if base == "" then
    vim.notify("No merge base found for HEAD and " .. branch, vim.log.levels.ERROR)
    vim.cmd("Git diff --name-only")
    return
  end

  vim.cmd("Git diff --name-only " .. base)
end

vim.api.nvim_create_user_command("GitChanges", function(opts)
  git_diff_from(opts.args)
end, { nargs = "?", complete = "shellcmd", desc = "Git changed files from given branch, defaults to merge-base with main/master." })
