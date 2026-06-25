-- ~/.config/nvim/lua/plugins/lint.lua
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        -- For markdownlint-cli2
        args = { "--disable", "MD013", "--" },
      },
      -- If using standard markdownlint instead:
      -- markdownlint = {
      --   args = { "--disable", "MD013", "--" },
      -- },
    },
  },
}
