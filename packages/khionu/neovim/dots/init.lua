vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.grepprg = "rg --vimgrep"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

plugins = {
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
  { 
    "nvim-treesitter/nvim-treesitter",
    name = "treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = "all",
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
        }
      })
    end,
  },
  "avm99963/vim-jjdescription",
  {
    "kylechui/nvim-surround",
    version = "*", -- "*" for latest, "main" for dev
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
            -- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt
        })
    end,
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    lazy = true,
    config = false,
    init = function()
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {"L3MON4D3/LuaSnip"},
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      lsp_zero.extend_cmp()

      local cmp = require("cmp")
      local cmp_action = lsp_zero.cmp_action()

      cmp.setup({
        formatting = lsp_zero.cmp_format({details = true}),
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-f>"] = cmp_action.luasnip_jump_forward(),
          ["<C-b>"] = cmp_action.luasnip_jump_backward(),
        }),
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    cmd = "LspInfo",
    event = {"BufReadPre", "BufNewFile"},
    dependencies = {
      {"hrsh7th/cmp-nvim-lsp"},
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim"
        },
      },
      {
        "kevinhwang91/nvim-ufo",
        dependencies = {
          "kevinhwang91/promise-async"
        },
        config = function()
          vim.o.foldcolumn = "1"
          vim.o.foldlevel = 99
          vim.o.foldlevelstart = 99
          vim.o.foldenable = true

          vim.keymap.set("n", "zR", require("ufo").openAllFolds)
          vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
        end,
      },
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      lsp_zero.extend_lspconfig()

      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({buffer = bufnr})

        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navbuddy").attach(client, bufnr)
        end
      end)

      lsp_zero.set_server_config({
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            }
          }
        }
      })

      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      lspconfig.rust_analyzer.setup({
        on_attach = function(client, bufnr)
          vim.lsp.inlay_hint.enable(bufnr)
        end,
      })
   
      local lexical_config = {
        filetypes = { "elixir", "eelixir", "heex" },
        cmd = { "/my/home/projects/_build/dev/package/lexical/bin/start_lexical.sh" },
        settings = {},
      }
   
      if not configs.lexical then
        configs.lexical = {
          default_config = {
            filetypes = lexical_config.filetypes,
            cmd = lexical_config.cmd,
            root_dir = function(fname)
              return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or vim.loop.os_homedir()
            end,
            -- optional settings
            settings = lexical_config.settings,
          },
        }
      end

      lsp_zero.setup_servers({"rust_analyzer", "tsserver", "lexical", "slint_lsp"})
    end
  },
}

-- Ada                                 | `als`                             |
-- Angular                             | `angularls`                       |
-- Ansible                             | `ansiblels`                       |
-- Arduino                             | `arduino_language_server`         |
-- Assembly (GAS/NASM, GO)             | `asm_lsp`                         |
-- Automake                            | `autotools_ls`                    |
-- Azure Pipelines                     | `azure_pipelines_ls`              |
-- Bash                                | `bashls`                          |
-- Buf                                 | `bufls`                           |
-- C                                   | `clangd`                          |
-- C# [(docs)][omnisharp]              | `omnisharp`                       |
-- C++                                 | `clangd`                          |
-- Cairo                               | `cairo_ls`                        |
-- CMake                               | `neocmake`                        |
-- CSS                                 | `unocss`                          |
-- Clojure                             | `clojure_lsp`                     |
-- CodeQL                              | `codeqlls`                        |
-- Autoconf                            | `autotools_ls`                    |
-- Cypher                              | `cypher_ls`                       |
-- Deno                                | `denols`                          |
-- Dhall                               | `dhall_lsp_server`                |
-- Diagnostic (general purpose server) | `diagnosticls`                    |
-- Docker                              | `dockerls`                        |
-- Docker Compose                      | `docker_compose_language_service` |
-- Dot                                 | `dotls`                           |
-- Drools                              | `drools_lsp`                      |
-- ESLint                              | `eslint`                          |
-- F#                                  | `fsautocomplete`                  |
-- Go                                  | `gopls`                           |
-- Gradle                              | `gradle_ls`                       |
-- Grammarly                           | `grammarly`                       |
-- GraphQL                             | `graphql`                         |
-- HDL                                 | `hdl_checker`                     |
-- HTML                                | `html`                            |
-- HTMX                                | `htmx`                            |
-- Haskell                             | `hls`                             |
-- JSON                                | `biome`                           |
-- JavaScript                          | `biome`                           |
-- Jinja                               | `jinja_lsp`                       |
-- Julia [(docs)][julials]             | `julials`                         |
-- Kotlin                              | `kotlin_language_server`          |
-- LaTeX                               | `texlab`                          |
-- Lua                                 | `lua_ls`                          |
-- Luau                                | `luau_lsp`                        |
-- Make                                | `autotools_ls`                    |
-- Pest                                | `pest_ls`                         |
-- Pico8                               | `pico8_ls`                        |
-- Powershell                          | `powershell_es`                   |
-- Prisma                              | `prismals`                        |
-- Puppet                              | `puppet`                          |
-- R                                   | `r_language_server`               |
-- ReScript                            | `rescriptls`                      |
-- Robot Framework                     | `robotframework_ls`               |
-- Rust                                | `rust_analyzer`                   |
-- SQL                                 | `sqlls`                           |
-- Sass                                | `somesass_ls`                     |
-- Slint                               | `slint_lsp`                       |
-- Smithy                              | `smithy_ls`                       |
-- Standard ML                         | `millet`                          |
-- Starlark                            | `bzl`                             |
-- Svelte                              | `svelte`                          |
-- SystemVerilog                       | `verible`                         |
-- TOML                                | `taplo`                           |
-- Tailwind CSS                        | `tailwindcss`                     |
-- Terraform                           | `tflint`                          |
-- Typst                               | `typst_lsp`                       |
-- Veryl                               | `veryl_ls`                        |
-- Vue                                 | `volar`                           |
-- WGSL                                | `wgsl_analyzer`                   |
-- XML                                 | `lemminx`                         |
-- YAML                                | `hydra_lsp`                       |
-- Zig                                 | `zls`                             |

-- # These I need to do more research on
--  Python   | `pyre`                 |
--  Python   | `pyright`              |
--  Python   | `pylyzer`              |
--  Python   | `sourcery`             |
--  Python   | `pylsp`                |
--  Python   | `ruff_lsp`             |
--  Markdown | `markdown_oxide`       |
--  Markdown | `marksman`             |
--  Markdown | `prosemd_lsp`          |
--  Markdown | `remark_ls`            |
--  Markdown | `vale_ls`              |
--  Markdown | `zk`                   |
--  Nix      | `nil_ls`               |
--  Nix      | `rnix`                 |
--  Erlang   | `elp`                  |
--  Erlang   | `erlangls`             |
--  Java     | `jdtls`                |
--  Java     | `java_language_server` |
--  GLSL     | `glsl_analyzer`        |
--  GLSL     | `glslls`               |

require("lazy").setup(plugins)

vim.cmd [[colorscheme moonfly]]

