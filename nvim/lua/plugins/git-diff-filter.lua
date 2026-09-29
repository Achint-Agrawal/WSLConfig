-- <leader>gd picker: <a-s> cycles all -> unstaged -> staged changes. <leader>gu opens unstaged only.
local function set_filter(picker, staged)
  picker.opts.staged = staged
  picker.title = staged == nil and "Git Diff" or staged and "Git Diff (staged)" or "Git Diff (unstaged)"
  picker:update_titles()
  picker.list:set_target()
  picker:find()
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_diff = {
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
