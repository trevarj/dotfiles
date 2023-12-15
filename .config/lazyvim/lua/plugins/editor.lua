return {
  -- add telescope-fzf-native
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "trevarj/telescope-tmux.nvim", dev = false, branch = "develop" },
      { "norcalli/nvim-terminal.lua" }, -- mostly for tmux pane contents
    },
    keys = {
      {
        "<leader>fc",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Search for word under cursor",
      },
      {
        "<leader>fl",
        "<cmd>Telescope resume<cr>",
        desc = "Resume last search",
      },
      {
        "<leader>j",
        function()
          require("telescope.builtin").jumplist()
        end,
        desc = "Jumplist",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").find_files({
            no_ignore = true,
            hidden = true,
          })
        end,
        desc = "Find Files (cwd, no ignore)",
      },
    },
    -- apply the config and additionally load fzf-native
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      opts.defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Del>"] = actions.delete_buffer,
          },
          n = {
            ["q"] = actions.close,
          },
        },
      }
      opts.extensions = {
        tmux = {
          grep_cmd = "rg -oe",
        },
      }
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("tmux")
    end,
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gd",
        function()
          local lib = require("diffview.lib")
          local view = lib.get_current_view()
          if view then
            -- Current tabpage is a Diffview; close it
            vim.cmd(":DiffviewClose")
          else
            -- No open Diffview exists: open a new one
            vim.cmd(":DiffviewOpen")
          end
        end,
        desc = "Diff View",
      },
    },
    opts = {
      view = {
        merge_tool = {
          disable_diagnostics = true,
        },
      },
    },
  },
  {
    "lewis6991/spaceless.nvim",
    config = true,
    lazy = false,
  },
  {
    "norcalli/nvim-terminal.lua",
    config = true,
  },
}
