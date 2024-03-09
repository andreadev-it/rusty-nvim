local M = {}

local nmap = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { desc = desc })
end

local vmap = function(keys, func, desc)
    vim.keymap.set("v", keys, func, { desc = desc })
end

M.overview = function ()
    return {
        ["<leader>c"] = { name = "[C]rates", _ = "which_key_ignore" },
        ["<leader>C"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]indow", _ = "which_key_ignore" },
        ["<leader>W"] = { name = "[W]orkspace", _ = "which_key_ignore" },
        ["<leader>t"] = { name = "[T]ab", _ = "which_key_ignore" },
    }
end

-- Basic keybindings for general purpose
M.basic = function()
    -- [[ Basic Keymaps ]]
    --  See `:help vim.keymap.set()`

    -- Set highlight on search (see options), but clear on pressing <Esc> in normal mode
    nmap("<Esc>", "<cmd>nohlsearch<CR>")

    -- Diagnostic keymaps
    nmap("[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
    nmap("]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
    nmap("<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
    nmap("<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

    -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
    -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
    -- is not what someone will guess without a bit more experience.
    --
    -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
    -- or just use <C-\><C-n> to exit terminal mode
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

    -- Keybinds to make split navigation easier.
    --  Use CTRL+<hjkl> to switch between windows
    --
    --  See `:help wincmd` for a list of all window commands
    nmap("<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
    nmap("<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
    nmap("<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
    nmap("<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

    -- Keybinds for easily splitting and closing windows
    nmap("<leader>wh", ":split<cr>", { desc = "Split [W]indow [H]orizontally" })
    nmap("<leader>wv", ":vsplit<cr>", { desc = "Split [W]indow [V]ertically" })
    nmap("<leader>wc", ":close<cr>", { desc = "[W]indow [C]lose" })

    -- Keybinds for tabs
    nmap("<leader>tn", ":tabnew<cr>", { desc = "[T]ab [N]ew" })
end

-- Telescope specific keybindings
M.telescope = function()
    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")
    nmap("<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    nmap("<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    nmap("<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    nmap("<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
    nmap("<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    nmap("<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    nmap("<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    nmap("<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    nmap("<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    nmap("<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

    -- CTRL+P alias for finding files
    nmap("<C-p>", builtin.find_files, { desc = "Search Files (alias)" })

    -- Slightly advanced example of overriding default behavior and theme
    nmap("<leader>/", function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            previewer = false,
        }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    nmap("<leader>s/", function()
        builtin.live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
        })
    end, { desc = "[S]earch [/] in Open Files" })

    -- Shortcut for searching your neovim configuration files
    nmap("<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[S]earch [N]eovim files" })
end

-- LSP Keybindings
M.LSP = function (event)

    local lspmap = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-T>.
    lspmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

    -- Find references for the word under your cursor.
    lspmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    lspmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    lspmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    lspmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

    -- Fuzzy find all the symbols in your current workspace
    --  Similar to document symbols, except searches over your whole project.
    lspmap(
        "<leader>Ws",
        require("telescope.builtin").lsp_dynamic_workspace_symbols,
        "[W]orkspace [S]ymbols"
    )

    -- Rename the variable under your cursor
    --  Most Language Servers support renaming across files, etc.
    lspmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    lspmap("<leader>Ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    -- Opens a popup that displays documentation about the word under your cursor
    --  See `:help K` for why this keymap
    lspmap("K", vim.lsp.buf.hover, "Hover Documentation")

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header
    lspmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
end

-- Bindings for Completion plugin (cmp)
M.CMP = function ()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    -- For an understanding of why these mappings were
    -- chosen, you will need to read `:help ins-completion`
    return {
        -- Select the [n]ext item
        ["<C-n>"] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ["<C-p>"] = cmp.mapping.select_prev_item(),

        -- Accept the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ["<C-Space>"] = cmp.mapping.complete({}),

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { "i", "s" }),
    }
end

-- Keymaps for the crates.nvim package
M.crates_nvim = function ()

    local cratesmap = function(keys, func, desc)
        nmap(keys, func, { desc = "[C]rates: " .. desc, silent = true })
    end

    local cratesvmap = function(keys, func, desc)
        vmap(keys, func, { desc = "[C]rates: " .. desc, silent = true })
    end

    local crates = require('crates')

    cratesmap('<leader>ct', crates.toggle, '[T]oggle plugin')
    cratesmap('<leader>cr', crates.reload, '[R]eload plugin')

    cratesmap('<leader>cv', crates.show_versions_popup, '[V]ersions popup')
    cratesmap('<leader>cf', crates.show_features_popup, '[F]eatures popup')
    cratesmap('<leader>cd', crates.show_dependencies_popup, '[D]ependencies popup')

    cratesmap('<leader>ce', crates.expand_plain_crate_to_inline_table, '[E]xpand crate')
    cratesmap('<leader>cE', crates.extract_crate_into_table, '[E]xtract crate')

    cratesmap('<leader>cu', crates.update_crate, '[U]pdate crate')
    cratesvmap('<leader>cu', crates.update_crates, '[U]pdate selected crates')
    cratesmap('<leader>ca', crates.update_all_crates, 'Update [a]ll crates')
    cratesmap('<leader>cU', crates.upgrade_crate, '[U]pgrade crate')
    cratesvmap('<leader>cU', crates.upgrade_crates, '[U]pgrade selected crates')
    cratesmap('<leader>cA', crates.upgrade_all_crates, 'Upgrade [a]ll crates')

    cratesmap('<leader>cH', crates.open_homepage, 'Open [H]omepage')
    cratesmap('<leader>cR', crates.open_repository, 'Open [R]epository')
    cratesmap('<leader>cD', crates.open_documentation, 'Open [D]ocumentation')
    cratesmap('<leader>cC', crates.open_crates_io, 'Open [C]rates.io')
end

return M
