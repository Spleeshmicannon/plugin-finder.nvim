local M = {}

function M.fetch(url)
    local result = vim.fn.system({ "curl", "-s", url })

    if vim.v.shell_error == 0 then
        return result
    end

    vim.notify("Failed to fetch data from " .. url, vim.log.levels.ERROR)
    return nil
end

function M.parse_neovimcraft_data(data)
    local plugins = {}
    local lines = vim.split(data, "\n", { plain = true })
    for i, line in ipairs(lines) do
        if i ~= 1 then
            local items = vim.split(line, "%s+", { trimempty = true })

            table.insert(plugins, {
                name = items[1],
                stars = items[2],
                open_issues = items[3],
                updated = items[4],
                description = items[5]
            })
        end
    end

    return plugins
end

return M
