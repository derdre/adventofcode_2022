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

local function split_line(line)
    local direction, range = line:match('(%u) (%d+)')
    return direction, tonumber(range)
end

local function add_vec(vec1, vec2)
    assert(#vec1 == #vec2)
    local vec_sum = {}

    for i = 1, #vec1 do
        vec_sum[i] = vec1[i] + vec2[i]
    end

    return vec_sum
end

local function sub_vec(vec1, vec2)
    assert(#vec1 == #vec2)
    local vec_sub = {}

    for i = 1, #vec1 do
        vec_sub[i] = vec1[i] - vec2[i]
    end

    return vec_sub
end

local function norm_vec(vec)
    local sum_sq = 0

    for i = 1, #vec do
        sum_sq = sum_sq + vec[i] * vec[i]
    end

    return math.sqrt(sum_sq)
end

local function move_vec(vec, direction)
    -- moves coords by one
    local direction_map = { U = { 0, 1 }, D = { 0, -1 }, L = { -1, 0 }, R = { 1, 0 } }
    local step = direction_map[direction]

    return add_vec(vec, step)
end

local function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

local function shrink_vec(vec)
    for i = 1, #vec do
        vec[i] = sign(vec[i]) * 1
    end
    return vec
end

local function adjust_tail(head, tail)
    local ht_sub = sub_vec(head, tail)
    local ht_sub_norm = norm_vec(ht_sub)
    if ht_sub_norm > 3.0 then
        error('Unrecognized state with head-tail-distance: ' .. ht_sub_norm)
    elseif ht_sub_norm > 2.0 then
        local ht_sub_shrink = shrink_vec(ht_sub)
        tail = add_vec(tail, ht_sub_shrink)
    elseif ht_sub_norm == 2.0 then
        local ht_sub_shrink = shrink_vec(ht_sub)
        tail = add_vec(tail, ht_sub_shrink)
    elseif ht_sub_norm < 2.0 then
    else
        error('Unrecognized state with head-tail-distance: ' .. ht_sub_norm)
    end

    return tail
end

local function tbl_to_str(tbl)
    local out = ''
    for _, v in ipairs(tbl) do
        out = out .. tostring(v) .. '/'
    end
    return out:sub(1, #out - 1)
end

local function to_set(tbl)
    local set = {}
    for _, el in ipairs(tbl) do set[el] = true end
    return set
end

local function get_unique_positions(tbl)
    local set = to_set(tbl)
    local set_length = 0
    for k, v in pairs(set) do
        set_length = set_length + 1
    end
    return set_length
end

local function main()
    local input_name, knots = args[1], args[2]
    if input_name == nil then
        print('No input file was provided.')
        return
    end

    local data = lines_from(input_name)
    local rope = {}
    for _ = 1, knots do
        table.insert(rope, { 0, 0 })
    end
    local tail_positions = {}

    for i = 1, #data do
        local direction, range = split_line(data[i])
        for _ = 1, range do
            rope[1] = move_vec(rope[1], direction)
            for k = 2, knots do
                rope[k] = adjust_tail(rope[k - 1], rope[k])
            end
            table.insert(tail_positions, tbl_to_str(rope[#rope]))
        end
    end

    local amount_tail_positions = get_unique_positions(tail_positions)

    print('The tail passes ' .. amount_tail_positions .. ' positions.')

end

main()
