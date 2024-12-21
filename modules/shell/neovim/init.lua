if vim.fn.has("nvim-0.11") == 0 then
  vim.notify("NativeVim only supports Neovim 0.11+", vim.log.levels.ERROR)
  return
end



function lua_ls_on_init(client)
    local path = vim.tbl_get(client,"workspace_folders", 1, "name")
    if not path then
        vim.print("no workspace")
        return
    end
    client.settings = vim.tbl_deep_extend('force', client.settings, {
        Lua = {
            runtime = {
                version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                }
                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                -- library = vim.api.nvim_get_runtime_file("", true)
            }
        }
    })
end



--
-- BASIC OPTIONS
--
vim.opt.diffopt:append("linematch:60")
vim.o.clipboard = "unnamedplus"
vim.o.completeopt = "menu,menuone,popup,fuzzy"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldcolumn = "0"
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.inccommand = "split"
vim.o.ignorecase = true
vim.o.list = true
vim.opt.listchars = {
    tab = "▏ ",
    trail = "·",
    extends = "»",
    precedes = "«",
}
vim.o.mouse = "nv"
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.showmode = true
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.undolevels = 10000
vim.o.updatetime = 200

vim.g.mapleader = " "

vim.g.editorconfig = true

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0





--
-- indent settings
--
vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })
local supported_filetypes = {}

local function set_indent(ft, indent, use_spaces)
    vim.api.nvim_create_autocmd("FileType", {
        group = "FileTypeIndent", 
        pattern = ft,
        callback = function()
            table.insert(supported_filetypes, ft)
            vim.bo.expandtab = use_spaces
            vim.bo.shiftwidth = indent
            vim.bo.tabstop = indent
            vim.bo.softtabstop = indent
        end,
    })
end

set_indent("lua", 2, true)
set_indent("nix", 2, true)
set_indent("python", 4, true)
set_indent("make", 4, false)

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    group = "FileTypeIndent",
    callback = function()
        if vim.bo.filetype == "" or not vim.tbl_contains(supported_filetypes, vim.bo.filetype) then
            vim.bo.expandtab = true
            vim.bo.shiftwidth = 2
            vim.bo.tabstop = 2
            vim.bo.softtabstop = 2
        end
    end,
})






--
-- TREESITTER
--
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end
})



--
-- LSP
--

-- NORMAL MODE
-- K        : hover
-- grn      : rename
-- gra      : code action
-- grr      : references
-- CTRL-]   : definition
-- CTRL-W_] : definition in new window
-- CTRL-W_} : definition in preview window
--
-- VISUAL MODE
-- gq : format
--
-- INSERT MODE
-- CTRL-S        : signature help
-- CTRL-X_CTRL-O : completion


---simple utility function to evaluate `vim.fs.root` on `FileType` events (#5)
---@see vim.fs.root
---@see lspconfig.util.root_pattern
local function root_pattern(marker)
    return function ()
        return vim.fs.root(0, marker)
    end
end

---server configurations copied from <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md>
---@type table<string, vim.lsp.ClientConfig>
local servers = {
    lua_ls = {
        name = "lua-language-server",
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        on_init = lua_ls_on_init,
        _root_dir = root_pattern({ ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" }),
    },
    nixd = {
      name = "nixd",
      cmd = { "nixd" },
      filetypes = { "nix" },
      --_root_dir = root_pattern({ "flake.nix" }),
    },
}
local group = vim.api.nvim_create_augroup("UserLspStart", { clear = true })
for _, config in pairs(servers) do
    if vim.fn.executable(config.cmd[1]) ~= 0 then
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = config.filetypes,
            callback = function (ev)
                if config._root_dir then
                    config.root_dir = config._root_dir()
                end
                vim.lsp.start(config, { bufnr = ev.buf })
            end,
        })
    end
end
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = false }),
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = false })
    end
})



---@param trigger string trigger string for snippet
---@param body string snippet text that will be expanded
---@param opts? vim.keymap.set.Opts
---
---Refer to <https://microsoft.github.io/language-server-protocol/specification/#snippet_syntax>
---for the specification of valid body.
function vim.snippet.add(trigger, body, opts)
    vim.keymap.set("ia", trigger, function()
        -- If abbrev is expanded with keys like "(", ")", "<cr>", "<space>",
        -- don't expand the snippet. Only accept "<c-]>" as trigger key.
        local c = vim.fn.nr2char(vim.fn.getchar(0))
        if c ~= "" then
            vim.api.nvim_feedkeys(trigger .. c, "i", true)
            return
        end
        vim.snippet.expand(body)
    end, opts)
end


-- this is default statusline value
-- vim.o.statusline = [[%f %h%w%m%r%=%-14.(%l,%c%V%) %P]]

-- below is simple example of custom statusline using neovim APIs

---Show attached LSP clients in `[name1, name2]` format.
---Long server names will be modified. For example, `lua-language-server` will be shorten to `lua-ls`
---Returns an empty string if there aren't any attached LSP clients.
---@return string
local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    end
    local it = vim.iter(attached_clients)
    it:map(function (client)
        local name = client.name:gsub("language.server", "ls")
        return name
    end)
    local names = it:totable()
    return "[" .. table.concat(names, ", ") .. "]"
end

function _G.statusline()
    return table.concat({
        "%f",
        "%h%w%m%r",
        "%=",
        lsp_status(),
        " %-14(%l,%c%V%)",
        "%P",
    }, " ")
end

vim.o.statusline = "%{%v:lua._G.statusline()%}"



vim.g.netrw_banner = 0



vim.keymap.set("n", "<leader><leader>", "<cmd>FZF<cr>", { desc = "Fuzzy Finder" })
