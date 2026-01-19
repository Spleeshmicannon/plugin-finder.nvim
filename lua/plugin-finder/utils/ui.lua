local M = {}

function M.create_window(spec)
    local window = {}

    window.buffer = vim.api.nvim_create_buf(false, true)

    -- Set buffer options to make it truly scratch
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = window.buffer })
    vim.api.nvim_set_option_value("swapfile", false, { buf = window.buffer })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = window.buffer })

    window.handle = vim.api.nvim_open_win(window.buffer, true, {
        relative = "editor",
        row = spec.row,
        col = spec.col,
        width = spec.width,
        height = spec.height,
        style = "minimal",
        border = { " " },
        title = spec.title,
        title_pos = "center"
    })

    local opts = { buffer = window.buffer, silent = true, nowait = true }

    vim.keymap.set("n", "q", function() M.close_window(window) end, opts)
    vim.keymap.set("n", "<Esc>", function() M.close_window(window) end, opts)

    vim.api.nvim_buf_set_lines(window.buffer, 0, -1, false, {})

    return window
end

function M.write_text(window, text, start_index)
    if start_index == nil then
        start_index = 0
    end
    vim.api.nvim_buf_set_lines(window.buffer, start_index, -1, false, text)
end

function M.display_node(window, node, index)
    if node.name == nil then
        return
    end

    local text = " ◍ " .. node.name
    if node.stars then
        text = text .. "  " .. node.stars
    end

    vim.api.nvim_buf_set_lines(
        window.buffer,
        index,
        index + 1,
        false,
        { text }
    )
end

function M.close_window(window)
    if window.handle and vim.api.nvim_win_is_valid(window.handle) then
        vim.api.nvim_win_close(window.handle, true)
    end
    if window.buffer and vim.api.nvim_buf_is_valid(window.buffer) then
        vim.api.nvim_buf_delete(window.buffer, { force = true })
    end
end

return M
