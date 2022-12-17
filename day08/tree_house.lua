local args = { ... }

local function file_exists(file_path)
    local f = io.open(file_path, 'rb')
    if f then f:close() end
    return f ~= nil
end

local function lines_from(file_path)
    if not file_exists(file_path) then return {} end
    local lines = {}

    for line in io.lines(file_path) do
        lines[#lines + 1] = line
    end

    return lines
end

local function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

local function array_from_input(data)
    local arr = {}
    for _, row_str in ipairs(data) do
        local row_arr = {}
        for i = 1, #row_str do
            local height = tonumber(row_str:sub(i, i))
            table.insert(row_arr, height)
        end
        table.insert(arr, row_arr)
    end
    return arr
end

local function any(tbl)
    for _, b in ipairs(tbl) do
        if b then return true end
    end
    return false
end

local function is_visible(row, col, arr)
    local rows, cols = #arr, #arr[1]
    local height = arr[row][col]
    local visibility_tbl = { true, true, true, true }

    for j = 1, col - 1 do -- columns left
        if arr[row][j] >= height then visibility_tbl[1] = false end
    end
    for j = col + 1, cols do -- columns right
        if arr[row][j] >= height then visibility_tbl[2] = false end
    end
    for i = 1, row - 1 do -- rows up
        if arr[i][col] >= height then visibility_tbl[3] = false end
    end
    for i = row + 1, rows do -- rows down
        if arr[i][col] >= height then visibility_tbl[4] = false end
    end

    return any(visibility_tbl)
end

local function get_scenic_score(row, col, arr)
    local rows, cols = #arr, #arr[1]
    local height = arr[row][col]
    local scores = { 0, 0, 0, 0 }

    for j = col - 1, 1, -1 do -- columns left
        scores[1] = scores[1] + 1
        if arr[row][j] >= height then break end
    end
    for j = col + 1, cols do -- columns right
        scores[2] = scores[2] + 1
        if arr[row][j] >= height then break end
    end
    for i = row - 1, 1, -1 do -- rows up
        scores[3] = scores[3] + 1
        if arr[i][col] >= height then break end
    end
    for i = row + 1, rows do -- rows down
        scores[4] = scores[4] + 1
        if arr[i][col] >= height then break end
    end

    return scores[1] * scores[2] * scores[3] * scores[4]
end

local function main()
    local input_name = args[1]
    if input_name == nil then
        print('No input file was provided.')
        return
    end

    local data = lines_from(input_name)
    local arr = array_from_input(data)

    local cols = #arr[1]
    local rows = #arr
    local edge_trees = 2 * rows + 2 * cols - 4
    local inner_trees = 0
    local scenic_scores = {}

    for i = 2, rows - 1 do
        for j = 2, cols - 1 do
            if is_visible(i, j, arr) then inner_trees = inner_trees + 1 end
        end
    end

    print('Total visible trees: ' ..
        edge_trees + inner_trees .. ' (' .. edge_trees .. '/' .. inner_trees .. ')')

    for i = 2, rows - 1 do
        for j = 2, cols - 1 do
            local scenic_score = get_scenic_score(i, j, arr)
            table.insert(scenic_scores, scenic_score)
        end
    end

    print('\n----------\n')
    table.sort(scenic_scores, function(a, b) return a > b end)
    print('The highest scenic score is: ' .. scenic_scores[1])

end

main()
