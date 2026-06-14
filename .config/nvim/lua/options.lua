vim.g.netrw_banner = 0          -- Removes netrw banner

vim.opt.nu = true               -- Enable number lines
vim.opt.relativenumber = true   -- Enable relative number lines

-- Tab options --
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false            -- Disable wrapping
vim.opt.smartindent = true      -- Enable smart indenting
--vim.opt.incommand = "split"   -- Not working?

-- Split direction options --
vim.opt.splitbelow = true       
vim.opt.splitright = true

vim.opt.ignorecase = true       -- Search ignore case
vim.opt.smartcase = true        -- Search smart case
vim.opt.laststatus = 3          -- Status bar covers entire terminal even when split

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"  -- Allow persistant undoing
vim.opt.undofile = true

vim.opt.clipboard:append("unnamedplus")     -- Use system clipboard
vim.opt.isfname:append("@-@")
vim.opt.guicursor = ""
vim.opt.scrolloff = 8

vim.opt.colorcolumn = "0"
vim.opt.signcolumn = "yes"
vim.o.cmdheight = 0

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch", -- The color group used for the flash
      timeout = 150,         -- Duration of the flash in milliseconds
    })
  end,
})
