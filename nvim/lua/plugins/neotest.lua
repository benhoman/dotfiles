-- return {
--   "nvim-neotest/neotest",
--   opts = {
--     adapters = {
--       ["neotest-python"] = {
--         runner = "ca test",
--       },
--     },
--   },
-- }
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-python",
  },
  opts = {
    adapters = {
      ["neotest-python"] = {
        -- Here you can specify the settings for the adapter, i.e.
        runner = "ca test",
        -- python = ".venv/bin/python",
      },
    },
  },
}
