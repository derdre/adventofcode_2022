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

local function get_numbers(assignment)
    local left, right = string.match(assignment, '([^,]+),([^,]+)')
    local left_min, left_max = string.match(left, '(%d+)-(%d+)')
    local right_min, right_max = string.match(right, '(%d+)-(%d+)')
    return tonumber(left_min), tonumber(left_max), tonumber(right_min),
        tonumber(right_max)
end

local function check_full_overlap(left_min, left_max, right_min, right_max)
    if right_min <= left_min and left_max <= right_max then
        return 1
    elseif left_min <= right_min and right_max <= left_max then
        return 1
    else
        return 0
    end
end

local function check_partial_overlap(left_min, left_max, right_min, right_max)
    if right_max < left_min then
        return 0
    elseif left_max < right_min then
        return 0
    else
        return 1
    end
end

local function main()
    local file_name, overlap_type = args[1], args[2]
    if file_name == nil then
        print('No input file was provided.')
        return
    end

    print('Using file: "' .. file_name .. '"')
    local assignments = lines_from(file_name)
    print('Input file has ' .. tostring(#assignments) .. ' lines')

    local sum_inclusive = 0
    for i = 1, #assignments do
        local left_min, left_max, right_min, right_max = get_numbers(assignments[i])
        local is_overlap = 0
        if overlap_type == 'full' then
            is_overlap = check_full_overlap(left_min, left_max, right_min, right_max)
        elseif overlap_type == 'partial' then
            is_overlap = check_partial_overlap(left_min, left_max, right_min, right_max)
        else
            error('Unknown overlap type "' .. overlap_type .. '"')
        end
        sum_inclusive = sum_inclusive + is_overlap
    end
    print('Amount of ' .. overlap_type .. ' overlaps: ' .. tostring(sum_inclusive))

end

main()
