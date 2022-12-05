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

local function slice_table(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end
    return sliced
end

local function split_input(input_table)
    local stack = slice_table(input_table, 1, 9)
    local instructions = slice_table(input_table, 11, #input_table)
    return stack, instructions
end

local function get_letters_from_row(row)
    local letters = {}
    for i = 1, 9 do
        local str_pos = 2 + (i - 1) * 4
        letters[i] = string.sub(row, str_pos, str_pos)
    end
    return letters
end

local function transpose(stack)
    local stack_transpose = {}
    for i = 1, 9 do
        stack_transpose[i] = {}
        for j = 1, 8 do
            stack_transpose[i][j] = stack[j][i]
        end
    end
    return stack_transpose
end

local function reformat_stack(stack)
    local stack_rows = {}
    for i = 8, 1, -1 do
        local stack_row = stack[i]
        local letters_row = get_letters_from_row(stack_row)
        stack_rows[9 - i] = letters_row
    end
    local stack_transpose = transpose(stack_rows)
    return stack_transpose
end

local function remove_spaces(stack)
    local stack_no_space = {}
    for _, col in ipairs(stack) do
        local hight = #col
        for i = #col, 1, -1 do
            local l = col[i]
            if l == ' ' then
                hight = i - 1
            elseif l:match('%l') then
                break
            end
        end
        stack_no_space[#stack_no_space + 1] = slice_table(col, 1, hight)
    end
    return stack_no_space
end

local function split_instruction(instruction)
    local move, from, to = string.match(instruction, '%l+ (%d+) %l+ (%d+) %l+ (%d+)')
    return tonumber(move), tonumber(from), tonumber(to)
end

local function remove_from_table(stack, move, from)
    if type(move) ~= 'number' or move < 1 then
        return stack
    end
    local returns = {}
    for _ = 1, move do
        local removed = table.remove(stack[from])
        table.insert(returns, removed)
    end
    return stack, returns
end

local function append_to_table(stack, appendix, to)
    if appendix == nil or #appendix == 0 then
        return stack
    end
    for _ = 1, #appendix do
        local l = table.remove(appendix) -- not nice
        table.insert(stack[to], l)
    end
    return stack
end

local function do_bulk_move(stack, move, from, to)
    local removed
    stack, removed = remove_from_table(stack, move, from)
    stack = append_to_table(stack, removed, to)
    return stack
end

local function get_top_crates(stack)
    local str_out = ''
    for _, col in ipairs(stack) do
        str_out = str_out .. col[#col]
    end
    return str_out
end

local function main()
    local file_name = args[1]
    if file_name == nil then
        print('No input file was provided.')
        return
    end

    print('Using file: "' .. file_name .. '"')
    local input_table = lines_from(file_name)

    local stack, instructions = split_input(input_table)
    local stack_reformat = reformat_stack(stack)
    local stack_process = remove_spaces(stack_reformat)

    for i = 1, #instructions do
        local move, from, to = split_instruction(instructions[i])
        stack_process = do_bulk_move(stack_process, move, from, to)
    end
    local str_out = get_top_crates(stack_process)
    print('The top crates are: ' .. str_out)

end

main()
