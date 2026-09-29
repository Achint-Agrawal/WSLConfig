-- <leader>gd picker: <a-s> cycles all -> unstaged -> staged changes. <leader>gu opens unstaged only.
-- Untracked files are listed too (git diff omits them) in the all/unstaged views.
local function set_filter(picker, staged)
  picker.opts.staged = staged
  picker.title = staged == nil and "Git Diff" or staged and "Git Diff (staged)" or "Git Diff (unstaged)"
  picker:update_titles()
  picker.list:set_target()
  picker:find()
end

-- git diff hunks, plus untracked files unless showing staged-only or diffing against a base
local function finder(opts, ctx)
  local diff = require("snacks.picker.source.git").diff(opts, ctx)
  return function(cb)
    diff(cb)
    if opts.staged or opts.base then
      return
    end
    local cwd = ctx:git_root()
    require("snacks.picker.source.proc").proc(
      ctx:opts({
        cmd = "git",
        args = { "--no-pager", "ls-files", "--others", "--exclude-standard" },
        cwd = cwd,
        transform = function(item)
          item.file, item.cwd, item.status = item.text, cwd, "??"
        end,
      }),
      ctx
    )(cb)
  end
end

local function preview(ctx)
  if ctx.item.status == "??" then
    return Snacks.picker.preview.file(ctx)
  end
  return Snacks.picker.preview.diff(ctx)
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_diff = {
          finder = finder,
          preview = preview,
          actions = {
            git_diff_cycle = function(picker)
              local cur = picker.opts.staged
              if cur == nil then
                set_filter(picker, false)
              elseif cur == false then
                set_filter(picker, true)
              else
                set_filter(picker, nil)
              end
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-s>"] = { "git_diff_cycle", mode = { "n", "i" }, desc = "Cycle all/unstaged/staged" },
              },
            },
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader>gu",
      function()
        Snacks.picker.git_diff({ staged = false, title = "Git Diff (unstaged)" })
      end,
      desc = "Git Diff (unstaged)",
    },
  },
}
