local M = {}

local calc = require("plugin-finder.utils.calc")
local ui = require("plugin-finder.utils.ui")
local net = require("plugin-finder.utils.net")
local active_page = 1

local categories = require("plugin-finder.categories")

local function calculate_dimensions(width_precent, height_precent)
    local width = (vim.o.columns * width_precent) / 100
    local height = (vim.o.lines * height_precent) / 100

    return { width = math.floor(width + 0.5), height = math.floor(height + 0.5) }
end

local function show_menu(window)
    local cursor = 0
    for _, cat in ipairs(categories) do
        cat.start_col = cursor

        cursor = cursor + string.len(cat.string)
        cat.end_col = cursor

        vim.api.nvim_buf_set_text(
            window.buffer,
            0,
            cat.start_col,
            0,
            -1,
            { cat.string .. " " }
        )

        cursor = cursor + 1
    end

    -- Create namespace for highlights
    local ns_id = vim.api.nvim_create_namespace('menu_buttons')
    vim.api.nvim_buf_clear_namespace(window.buffer, ns_id, 0, -1)

    -- Add highlights for each category
    for _, cat in ipairs(categories) do
        local hl_group = "Pmenu"
        if active_page == cat.index then
            hl_group = "PmenuSel"
        end

        vim.api.nvim_buf_add_highlight(
            window.buffer,
            ns_id,
            hl_group,
            0,
            cat.start_col,
            cat.end_col
        )
    end
end

local function show_plugin_list(window)
    ui.write_text(window, { "loading plugins..." }, 2)
    vim.cmd("redraw")

    coroutine.resume(categories[active_page].co)
    while categories[active_page].data == nil do end -- wait for plugins to load

    ui.write_text(window, { " ", "Available Plugins:" }, 1)
    vim.api.nvim_buf_add_highlight(window.buffer, -1, "Title", 2, 0, -1)

    for i, item in ipairs(categories[active_page].data) do
        ui.display_node(window, item, i + 2)
    end
end

local function refresh_page(window, index)
    active_page = index
    show_menu(window)
    show_plugin_list(window)
end

local function show_ui()
    local dims = calculate_dimensions(70, 70)

    local window = ui.create_window({
        row = calc.centre(dims.height, vim.o.lines),
        col = calc.centre(dims.width, vim.o.columns),
        width = dims.width,
        height = dims.height,
        title = "Plugin Manager"
    })

    show_menu(window)

    local opts = { noremap = true, silent = true, buffer = window.buffer }
    for i,_ in ipairs(categories) do
        vim.keymap.set('n', vim.inspect(i), function() refresh_page(window, i) end, opts)
    end

    show_plugin_list(window)
end

function M.setup()
    for _, cat in ipairs(categories) do
        cat.co = coroutine.create(function()
            local res = net.fetch(cat.endpoint)
            cat.data = net.parse_neovimcraft_data(res)
        end)
    end
end

vim.api.nvim_create_user_command(
    "PluginFinder",
    function()
        show_ui()
    end,
    {}
)

return M
