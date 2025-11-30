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

local lsp_servers = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "clangd" }

require("lazy").setup({
  -- Syntax highlighting and language support
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_matchparen_hi_surround_always = 1
      vim.g.matchup_matchparen_offscreen = { method = 'status' }
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          tsx = 'rainbow-parens',
          javascript = 'rainbow-parens',
          typescript = 'rainbow-parens',
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

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
        ensure_installed = lsp_servers,
        automatic_enable = false,
      })
    end
  },
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        outline = {
          win_position = "right",
          win_width = 30,
          show_detail = true,
          auto_preview = false,
          auto_refresh = true,
          auto_close = true,
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
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        source_selector = {
          winbar = true,
        },
        window = {
          position = "left",
          width = 30,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
      })
      -- 让 Neo-tree 窗口不被其他窗口分割
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          local neo_tree_wins = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft == "neo-tree" then
              table.insert(neo_tree_wins, win)
            end
          end
          for _, win in ipairs(neo_tree_wins) do
            vim.api.nvim_win_set_option(win, "winfixwidth", true)
          end
        end,
      })
    end,
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

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      render_modes = { 'n', 'c', 't' },
      heading = {
        enabled = true,
        sign = false,
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        width = 'full',
        left_pad = 0,
        right_pad = 4,
        border = true,
        border_virtual = true,
      },
      code = {
        enabled = true,
        sign = false,
        style = 'full',
        width = 'block',
        border = 'thick',
        left_pad = 2,
        right_pad = 2,
        language_pad = 1,
        highlight = 'RenderMarkdownCode',
        highlight_language = 'RenderMarkdownCodeLanguage',
      },
      dash = {
        enabled = true,
        icon = '─',
        width = 'full',
      },
      bullet = {
        enabled = true,
        icons = { '◉', '○', '✸', '✿' },
        left_pad = 0,
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
        position = 'inline',
        unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
        checked = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked' },
        custom = {
          todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
          important = { raw = '[!]', rendered = ' ', highlight = 'DiagnosticWarn' },
          cancel = { raw = '[~]', rendered = '󰰱 ', highlight = 'RenderMarkdownError' },
        },
      },
      quote = {
        enabled = true,
        icon = '▎',
        repeat_linebreak = true,
      },
      pipe_table = {
        enabled = true,
        preset = 'round',
        style = 'full',
        cell = 'padded',
      },
      callout = {
        note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
        tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
        important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
        warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
        caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
      },
      link = {
        enabled = true,
        footnote = { superscript = true },
        image = '󰥶 ',
        email = '󰀓 ',
        hyperlink = '󰌹 ',
        custom = {
          github = { pattern = 'github%.com', icon = ' ' },
          youtube = { pattern = 'youtu%.?be', icon = '󰗃 ' },
        },
      },
      sign = { enabled = false },
      indent = { enabled = true, per_level = 2 },
      anti_conceal = { enabled = true },
    },
  },

  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "Macchiato",
        integrations = {
          cmp = true,
          gitsigns = true,
          mason = true,
          neotree = true,
          treesitter = true,
          lualine = true,
          fzf = true,
          render_markdown = true,
        },
      })
    end,
  },

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
vim.opt.showmatch = true                    -- Briefly highlight matching brackets
vim.opt.showcmd = true                      -- Show command in bottom bar
vim.opt.showmode = false                    -- Don't show mode (lualine already shows it)
vim.opt.cmdheight = 0                       -- Hide command line when not in use
vim.o.winbar = "%#Title#[%{winnr()}]%* %f" -- Show window number in winbar for easier jumping

-- Tabline configuration (managed by lualine)
vim.o.showtabline = 2                       -- Always show tabline

-- Additional performance settings
vim.opt.scrolljump = 5                      -- Jump 5 lines when scrolling off screen
vim.opt.sidescroll = 1                      -- Smooth horizontal scrolling
vim.opt.updatetime = 300                    -- Faster completion and diagnostics
vim.opt.timeoutlen = 500                    -- Faster key sequence timeout
vim.opt.termguicolors = true                -- Enable true color for better theme fidelity

-- Code folding settings
vim.opt.foldmethod = "expr"                -- Use Treesitter-aware folds by default
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- Fold based on syntax tree
vim.opt.foldnestmax = 20                    -- Allow deep nesting levels to fold
vim.opt.foldlevel = 1                       -- Show top-level context by default
vim.opt.foldlevelstart = 1                 -- Start buffers with shallow folds open
vim.opt.foldenable = true                   -- Make sure folding stays active

-- General settings
vim.opt.history = 1000                      -- Remember more commands and search history
vim.opt.encoding = "utf-8"                  -- Set default encoding

-- Ensure line numbers stay enabled on normal buffers
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function(event)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = event.buf })
    if buftype == '' then
      vim.opt_local.number = true
      vim.opt_local.relativenumber = true
    end
  end,
})

-- Fallback to indent-based folding when Treesitter is unavailable
vim.api.nvim_create_autocmd("FileType", {
  callback = function(event)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = event.buf })
    if buftype ~= '' then
      return
    end

    local ok = pcall(vim.treesitter.get_parser, event.buf)
    if not ok then
      vim.opt_local.foldmethod = "indent"
      vim.opt_local.foldexpr = ""
    end
  end,
})

-- Performance optimizations for syntax highlighting
vim.opt.synmaxcol = 200                     -- Limit syntax highlighting to 200 columns for performance
vim.opt.ttyfast = true                      -- Fast terminal connection for smoother rendering
vim.opt.lazyredraw = true                   -- Don't redraw while executing macros (performance)
vim.cmd("syntax enable")                    -- Enable syntax highlighting
vim.cmd("filetype plugin indent on")       -- Enable file type detection, plugins, and indentation

-- Reduce regex engine overhead for better performance
vim.opt.regexpengine = 1                    -- Use old regex engine for better performance

vim.cmd("colorscheme catppuccin")            -- Set Catppuccin color scheme

-- ==============================================================================
-- PLUGIN CONFIGURATION
-- ==============================================================================

-- Custom Claude Code status component
local function claude_code_status()
  -- Check if we're in a Claude Code session by looking for the CLAUDE_CODE environment variable
  local claude_active = vim.env.CLAUDE_CODE_SESSION or vim.env.CLAUDE_CODE

  if claude_active then
    return ' Claude'
  end

  return ''
end

-- Lualine configuration
local devicons = require('nvim-web-devicons')

require('lualine').setup {
  options = {
    theme = 'catppuccin',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {claude_code_status, 'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {
    lualine_a = {
      {
        'tabs',
        mode = 2,
        max_length = vim.o.columns,
        section_separators = { left = '', right = '' },
        fmt = function(name, context)
          local tabnr = context.tabnr
          local cwd = vim.fn.getcwd(-1, tabnr)
          local cwd_short = cwd:match('[^/]+$') or cwd

          local buflist = vim.fn.tabpagebuflist(tabnr)
          local winnr = vim.fn.tabpagewinnr(tabnr)
          local bufnr = buflist[winnr]
          local bufname = vim.fn.bufname(bufnr)

          local filename = bufname == '' and '[No Name]' or vim.fn.fnamemodify(bufname, ':t')
          local modified = vim.fn.getbufvar(bufnr, '&modified') == 1 and ' +' or ''

          -- Get file icon
          local ext = vim.fn.fnamemodify(bufname, ':e')
          local icon = devicons.get_icon(filename, ext, { default = true }) or ''

          return icon .. ' [' .. cwd_short .. '] ' .. filename .. modified
        end,
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  }
}

-- Treesitter configuration
require('nvim-treesitter.configs').setup{
  ensure_installed = { 'typescript', 'tsx', 'javascript', 'markdown', 'markdown_inline' },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  matchup = {
    enable = true,
  },
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function on_attach(_, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format { async = true }
  end, bufopts)
end

for _, server in ipairs(lsp_servers) do
  vim.lsp.config(server, {
    capabilities = capabilities,
    on_attach = on_attach,
  })
end

vim.lsp.enable(lsp_servers)

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
  pattern = {"javascript", "html", "css", "typescript", "typescriptreact"},
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

-- Git integration (open in top split, excluding Neo-tree area)
vim.api.nvim_set_keymap('n', '<leader>gg', '', {
  noremap = true,
  callback = function()
    -- 找到一个非 Neo-tree 的窗口
    local target_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if ft ~= "neo-tree" then
        target_win = win
        break
      end
    end

    if target_win then
      vim.api.nvim_set_current_win(target_win)
    end

    -- 在当前窗口上方打开 Git (aboveleft 保证不影响 Neo-tree)
    vim.cmd('aboveleft Git')

    -- 调整 fugitive 窗口高度为上半屏幕
    vim.schedule(function()
      local fugitive_win = vim.api.nvim_get_current_win()
      local total_height = vim.o.lines - vim.o.cmdheight - 2  -- 减去 tabline 和 statusline
      vim.api.nvim_win_set_height(fugitive_win, math.floor(total_height / 2))
    end)
  end
})

-- Open terminal
vim.api.nvim_set_keymap('n', '<leader>tt', ':term<CR>', { noremap = true })

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { silent = true, desc = 'Exit terminal to Normal mode' })

-- Diagnostics quick view
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true, desc = 'Diagnostics popup' })

-- LSPSaga keymaps
vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>Lspsaga outline<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pd', '<cmd>Lspsaga peek_definition<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pt', '<cmd>Lspsaga peek_type_definition<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ci', '<cmd>Lspsaga incoming_calls<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>Lspsaga outgoing_calls<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>>', ':<C-u>vertical resize +<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><', ':<C-u>vertical resize -<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>+', ':<C-u>resize +<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>-', ':<C-u>resize -<C-r>=v:count1<CR><CR>', { noremap = true, silent = true })
