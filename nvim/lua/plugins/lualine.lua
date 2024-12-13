return {
  -- Set lualine as statusline
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      icons_enabled = true,
      globalstatus = true,
    },
    sections = {
      lualine_c = { { "filename", path = 1 } },
    },
  },
}
