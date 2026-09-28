-- Send `@file:start-end` references from Neovim to a Copilot CLI running in another tmux pane.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Copilot" })
end

local function tmux(args, stdin)
  local res = vim.system(vim.list_extend({ "tmux" }, args), { stdin = stdin, text = true }):wait()
  if res.code ~= 0 then
    error(vim.trim(res.stderr or ""))
  end
  return vim.trim(res.stdout or "")
end

local function is_under(path, dir)
  local ok, rel = pcall(vim.fs.relpath, dir, path)
  return ok and rel ~= nil, rel
end

-- Copilot CLI sessions in tmux panes, discovered through sidekick.nvim
local function copilot_panes()
  local ok, Session = pcall(require, "sidekick.cli.session")
  if not ok then
    return {}
  end
  local panes = {}
  for _, s in ipairs(Session.sessions()) do
    if s.backend == "tmux" and s.tool.name == "copilot" and s.tmux_pane_id then
      panes[#panes + 1] = { id = s.tmux_pane_id, cwd = vim.fs.normalize(s.cwd) }
    end
  end
  return panes
end

local function with_pane(file, cb)
  local panes = copilot_panes()
  if #panes == 0 then
    return notify("No Copilot CLI found in a tmux pane", vim.log.levels.WARN)
  end
  -- Prefer the sessions whose cwd contains the file; deepest cwd first
  local matching = vim.tbl_filter(function(p)
    return (is_under(file, p.cwd))
  end, panes)
  table.sort(matching, function(a, b)
    return #a.cwd > #b.cwd
  end)
  local candidates = #matching > 0 and { matching[1] } or panes
  if #candidates == 1 then
    return cb(candidates[1])
  end
  vim.ui.select(candidates, {
    prompt = "Copilot CLI pane",
    format_item = function(p)
      return ("%s  %s"):format(p.id, p.cwd)
    end,
  }, function(p)
    if p then
      cb(p)
    end
  end)
end

---@param opts? { range?: boolean }
function M.send(opts)
  opts = opts or {}
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.bo.buftype ~= "" then
    return notify("Current buffer is not a file", vim.log.levels.WARN)
  end
  file = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))

  local suffix = ""
  if opts.range then
    local from, to = vim.fn.line("v"), vim.fn.line(".")
    if from > to then
      from, to = to, from
    end
    suffix = from == to and (":" .. from) or (":%d-%d"):format(from, to)
    vim.api.nvim_feedkeys(vim.keycode("<esc>"), "nx", false)
  end

  with_pane(file, function(pane)
    local under, rel = is_under(file, pane.cwd)
    local ref = "@" .. (under and rel or file) .. suffix .. " "
    local ok, err = pcall(function()
      local buffer = "copilot-ref"
      tmux({ "load-buffer", "-b", buffer, "-" }, ref)
      tmux({ "paste-buffer", "-p", "-d", "-b", buffer, "-t", pane.id })
      tmux({ "switch-client", "-t", pane.id })
      tmux({ "select-window", "-t", pane.id })
      tmux({ "select-pane", "-t", pane.id })
    end)
    if not ok then
      notify("Failed to send to Copilot: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

return M
