return {
  "vim-test/vim-test", -- "klen/nvim-test",
  config = function()
    vim.keymap.set("n", "<leader>tn", ":TestNearest<cr>")
    vim.keymap.set("n", "<leader>tf", ":TestFile<cr>")
    vim.keymap.set("n", "<leader>tl", ":TestLast<cr>")
    vim.keymap.set("n", "<leader>tv", ":TestVisit<cr>")
    vim.keymap.set("n", "<leader>tc", ":TestClass<cr>")
    vim.keymap.set("t", "<C-o>", "<C-\\><C-n>")

    vim.g["test#strategy"] = "floaterm"
    -- vim.g["test#strategy"] = "neovim"
    -- vim.g["test#neovim#term_position"] = "vert"
    vim.g["test#python#runner"] = "djangotest"
    vim.g["test#python#djangotest#executable"] = "ca test"
    vim.g["test#python#pytest#executable"] = "ca test"
  end,
  dependencies = {
    {
      "voldikss/vim-floaterm",
      config = function()
        vim.g["floaterm_height"] = 0.95
        vim.g["floaterm_width"] = 0.80
      end,
    },
  },
}
