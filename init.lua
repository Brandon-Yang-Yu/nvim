-- ==============================================================================
-- PLUGIN MANAGEMENT (lazy.nvim)
-- ==============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Syntax highlighting and language support
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP configuration
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "clangd" }
      })
    end
  },
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        outline = {
          win_position = "right",
          win_with = "",
          win_width = 30,
          preview_width = 0.4,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          custom_sort = nil,
          keys = {
            expand_or_jump = 'o',
            quit = "q",
          },
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    }
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    }
  },

  -- File searching and navigation
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },

  -- Rust development
  { "rust-lang/rust.vim" },

  -- Git integration
  { "tpope/vim-fugitive" },

  -- Theme
  { "tomasr/molokai" },

})

-- ==============================================================================
-- BASIC VIM SETTINGS
-- ==============================================================================

-- Indentation settings
vim.opt.expandtab = true                    -- Use spaces instead of tabs
vim.opt.tabstop = 4                         -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4                      -- Number of spaces to use for each step of autoindent
vim.opt.softtabstop = 4                     -- Number of spaces that a <Tab> counts for while editing
vim.api.nvim_set_keymap('i', '<Tab>', '<Space><Space><Space><Space>', { noremap = true })

-- Search settings
vim.opt.hlsearch = true                     -- Highlight all search matches
vim.opt.ignorecase = true                   -- Case-insensitive search
vim.opt.incsearch = true                    -- Show search matches as you type

-- User interface settings
vim.opt.laststatus = 2                      -- Always show status line
vim.opt.ruler = true                        -- Show cursor position in status line
vim.opt.wildmenu = true                     -- Enhanced command-line completion
vim.opt.cursorline = true                   -- Highlight current line
vim.opt.number = true                       -- Show line numbers
vim.opt.relativenumber = true               -- Show relative line numbers
vim.opt.showcmd = true                      -- Show command in bottom bar

-- Additional performance settings
vim.opt.scrolljump = 5                      -- Jump 5 lines when scrolling off screen
vim.opt.sidescroll = 1                      -- Smooth horizontal scrolling
vim.opt.updatetime = 300                    -- Faster completion and diagnostics
vim.opt.timeoutlen = 500                    -- Faster key sequence timeout

-- Code folding settings
vim.opt.foldmethod = "indent"               -- Fold based on indentation
vim.opt.foldnestmax = 3                     -- Maximum fold nesting level

-- General settings
vim.opt.history = 1000                      -- Remember more commands and search history
vim.opt.encoding = "utf-8"                  -- Set default encoding

-- Performance optimizations for syntax highlighting
vim.opt.synmaxcol = 200                     -- Limit syntax highlighting to 200 columns for performance
vim.opt.ttyfast = true                      -- Fast terminal connection for smoother rendering
vim.opt.lazyredraw = true                   -- Don't redraw while executing macros (performance)
vim.cmd("syntax enable")                    -- Enable syntax highlighting
vim.cmd("filetype plugin indent on")       -- Enable file type detection, plugins, and indentation

-- Reduce regex engine overhead for better performance
vim.opt.regexpengine = 1                    -- Use old regex engine for better performance

-- Theme
vim.cmd("colorscheme molokai")              -- Set color scheme

-- ==============================================================================
-- PLUGIN CONFIGURATION
-- ==============================================================================

-- Lualine configuration
require('lualine').setup {
  options = {
    theme = 'molokai',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
}

-- Treesitter configuration
require('nvim-treesitter.configs').setup{
  ensure_installed = { 'typescript', 'tsx', 'javascript' },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- LSP configuration
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup language servers
local servers = { 'lua_ls', 'pyright', 'ts_ls', 'rust_analyzer', 'clangd' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    end,
  }
end

-- Setup nvim-cmp
local cmp = require'cmp'
local luasnip = require'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Project-specific path
vim.opt.path:append("/Users/yy/Project/UNP/unpv13e/**")  -- Add UNP project to search path

-- ==============================================================================
-- FILE TYPE SPECIFIC SETTINGS
-- ==============================================================================

-- Python files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.textwidth = 80
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.fileformat = "unix"
  end,
})

-- Web development files (JavaScript, HTML, CSS)
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"javascript", "html", "css"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Highlight trailing whitespace for Python and C files
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "c", "cpp"},
  callback = function()
    vim.fn.matchadd("BadWhitespace", "\\s\\+$")
  end,
})

-- ==============================================================================
-- KEY MAPPINGS
-- ==============================================================================

-- Set leader key
vim.g.mapleader = "\\"

-- Delete to void register (doesn't overwrite clipboard)
vim.api.nvim_set_keymap('n', '<leader>d', '"_d', { noremap = true })

-- FZF file finder
vim.api.nvim_set_keymap('n', '<leader>ff', ':FZF<CR>', { noremap = true })

-- Neo-tree file explorer
vim.api.nvim_set_keymap('n', '<leader>ee', ':Neotree toggle<CR>', { noremap = true })

-- Git integration
vim.api.nvim_set_keymap('n', '<leader>gg', ':Git<CR>', { noremap = true })

-- Open terminal
vim.api.nvim_set_keymap('n', '<leader>tt', ':term<CR>', { noremap = true })

-- LSPSaga keymaps
vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>Lspsaga outline<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pd', '<cmd>Lspsaga peek_definition<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pt', '<cmd>Lspsaga peek_type_definition<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ci', '<cmd>Lspsaga incoming_calls<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>Lspsaga outgoing_calls<CR>', { noremap = true, silent = true })

-- Window resize functions (accepts count, e.g., 20> to resize horizontally by 20)
vim.api.nvim_set_keymap('n', '>', ':<C-u>vertical resize +<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<', ':<C-u>vertical resize -<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '+', ':<C-u>resize +<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '-', ':<C-u>resize -<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
