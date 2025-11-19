-----------------------------------------------------------
-- Bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = true

-----------------------------------------------------------
-- rustaceanvim global config
-- NOTE: this must be set before the plugin loads
-----------------------------------------------------------
vim.g.rustaceanvim = {
  tools = {
    -- Inlay hints & hover actions (rustaceanvim wraps these nicely)
    inlay_hints = {
      auto = true,
      only_current_line = false,
      show_parameter_hints = true,
      parameter_hints_prefix = "ﰲ ",
      other_hints_prefix = " ",
    },
    hover_actions = {
      auto_focus = true,
    },
  },

  server = {
    on_attach = function(client, bufnr)
      -- LSP keymaps (buffer-local for Rust)
      local bufmap = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      bufmap("n", "K", vim.lsp.buf.hover, "LSP Hover")
      bufmap("n", "gd", vim.lsp.buf.definition, "Goto Definition")
      bufmap("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
      bufmap("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
      bufmap("n", "gr", vim.lsp.buf.references, "References")
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
      bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

      bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
      bufmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
      bufmap("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")

      -- Format on save for Rust (LSP)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,

    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },

        -- run checks on save
        checkOnSave = true,
        check = {
          command = "clippy",
        },

        procMacro = {
          enable = true,
        },
      },
    },
  },
}

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
require("lazy").setup({

  ---------------------------------------------------------
  -- Colorscheme
  ---------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  ---------------------------------------------------------
  -- Statusline
  ---------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  ---------------------------------------------------------
  -- File explorer
  ---------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup()

      -- Auto-close tree when quitting Neovim
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          pcall(vim.cmd, "NvimTreeClose")
        end,
      })
    end,
  },

  ---------------------------------------------------------
  -- Treesitter (better syntax/indent)
  ---------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "rust",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "python",
          "javascript",
          "html",
          "css",
          "java",
          "c_sharp",
          "go",
          "c",
          "cpp",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  ---------------------------------------------------------
  -- LSP core (new vim.lsp.config style)
  ---------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Shared capabilities for all non-Rust LSPs (used by vim.lsp.config)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Shared on_attach for non-Rust LSPs
      local function on_attach(client, bufnr)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        bufmap("n", "K", vim.lsp.buf.hover, "LSP Hover")
        bufmap("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        bufmap("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        bufmap("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
        bufmap("n", "gr", vim.lsp.buf.references, "References")
        bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
        bufmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
        bufmap("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")
      end

      -- Apply defaults to ALL LSP servers (non-Rust)
      vim.lsp.config("*", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Extra config for Lua (so it knows about `vim`)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
    end,
  },

  ---------------------------------------------------------
  -- Mason: installs LSP servers, formatters, linters
  ---------------------------------------------------------
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  ---------------------------------------------------------
  -- Mason-LSPConfig: bridge Mason <-> vim.lsp.config
  ---------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",    -- Lua
          "pyright",   -- Python
          "ts_ls",     -- TypeScript / JavaScript
          "html",      -- HTML
          "cssls",     -- CSS
          "jdtls",     -- Java
          "csharp_ls", -- C#
          "gopls",     -- Go
          "clangd",    -- C / C++
          -- Rust is handled separately by rustaceanvim
        },
        -- automatic_enable = true by default: it calls vim.lsp.enable()
      })
    end,
  },

  ---------------------------------------------------------
  -- nvim-lint: external linters (ruff, eslint_d, clangtidy, etc.)
  ---------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        -- Python
        python = { "ruff" },

        -- JS / TS
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },

        -- Go
        go = { "golangcilint" },

        -- C / C++
        c = { "clangtidy" },
        cpp = { "clangtidy" },

        -- Lua
        -- lua_ls LSP already provides good diagnostics for Lua,
        -- so we skip an external luacheck linter for now.
        -- lua = { "luacheck" },
      }

      -- Run linters on common events
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      -- Optional: manual trigger
      vim.keymap.set("n", "<leader>ll", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
    end,
  },

  ---------------------------------------------------------
  -- mason-nvim-lint: auto-install linters defined in nvim-lint
  ---------------------------------------------------------
  {
    "rshkarin/mason-nvim-lint",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-lint" },
    config = function()
      require("mason-nvim-lint").setup({
        -- keep auto-install for linters Mason *does* know about (ruff, eslint_d, etc.)
        automatic_installation = true,
        -- don't try to install these via Mason; they aren't in the registry / we manage manually
        ignore_install = { "clangtidy", "luacheck" },
      })
    end,
  },

  ---------------------------------------------------------
  -- Formatter: conform.nvim (format-on-save for non-Rust)
  ---------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          json = { "prettier" },
          go = { "gofmt" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          -- Rust is formatted via rustaceanvim / LSP, so we skip here.
        },
      })

      -- Format on save for everything except Rust (Rust handled separately)
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if ft == "rust" then
            return
          end
          conform.format({
            bufnr = args.buf,
            lsp_fallback = true,
            async = false,
          })
        end,
      })
    end,
  },

  ---------------------------------------------------------
  -- Rust LSP + tools (rust-analyzer etc)
  ---------------------------------------------------------
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
  },

  ---------------------------------------------------------
  -- Autocompletion: nvim-cmp + LuaSnip + sources
  ---------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  ---------------------------------------------------------
  -- Autopairs (auto-close (), {}, [], etc.)
  ---------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({})

      -- Integrate with nvim-cmp
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if cmp_status_ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  ---------------------------------------------------------
  -- Telescope (fuzzy finder: files, grep, etc.)
  ---------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
    end,
  },

  ---------------------------------------------------------
  -- Outline panel (symbols view)
  ---------------------------------------------------------
  {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = { default_direction = "prefer_right" },
      })
      vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Toggle outline" })
    end,
  },

  ---------------------------------------------------------
  -- Git signs in the gutter
  ---------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  ---------------------------------------------------------
  -- Git porcelain (Fugitive)
  ---------------------------------------------------------
  {
    "tpope/vim-fugitive",
  },

  ---------------------------------------------------------
  -- Debugging: nvim-dap + UI
  ---------------------------------------------------------
  ---------------------------------------------------------
-- Debugging: nvim-dap + UI
---------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
  },

  -- REQUIRED dependency for dap-ui
  {
    "nvim-neotest/nvim-nio",
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
  },
  
  config = function()
  local dap = require("dap")
  local dapui = require("dapui")

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle   Breakpoint" })
    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "DAP Conditional Breakpoint" })
  end,
},


})

-----------------------------------------------------------
-- Global keymaps
-----------------------------------------------------------

-- Toggle file explorer
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle NvimTree" })

-- Quick diagnostics list
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Basic better defaults for diagnostics UI
vim.diagnostic.config({
  virtual_text = true,
  float = { border = "rounded" },
})
