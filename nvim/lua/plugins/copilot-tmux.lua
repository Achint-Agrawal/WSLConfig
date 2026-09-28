return {
  {
    "folke/sidekick.nvim",
    keys = {
      {
        "<leader>ac",
        function()
          require("copilot_tmux").send({ range = true })
        end,
        mode = "x",
        desc = "Send Selection to Copilot (tmux)",
      },
      {
        "<leader>ac",
        function()
          require("copilot_tmux").send()
        end,
        desc = "Send File to Copilot (tmux)",
      },
    },
  },
}
