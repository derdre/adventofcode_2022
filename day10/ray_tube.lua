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
    local op, val = line:match('(%l+)%s?(%-?%d*)')
    return op, tonumber(val)
end

local function get_signal_sum_1(cycles)
    local support = { 20, 60, 100, 140, 180, 220 }
    local signal_sum = 0
    for _, s in ipairs(support) do
        signal_sum = signal_sum + s * cycles[s]
    end
    return signal_sum
end

local function generate_cycles(data)
    local registerx = 1
    local cycles = {}
    local c = 0
    local l = 0

    while true do
        l = l + 1
        if data[l] == nil then break end
        local op, val = split_line(data[l])

        if op == 'noop' then
            c = c + 1
            cycles[c] = registerx
        elseif op == 'addx' then
            c = c + 1
            cycles[c] = registerx
            c = c + 1
            cycles[c] = registerx
            registerx = registerx + val
        else
            error('Unrecognized state')
        end
    end
    return cycles
end

local function print_crt(crt)
    for _, r in ipairs(crt) do
        local row = ''
        for _, c in ipairs(r) do
            row = row .. c
        end
        print(row)
    end
end

local function main()
    local input_name, knots = args[1], args[2]
    if input_name == nil then
        print('No input file was provided.')
        return
    end

    local data = lines_from(input_name)

    local cycles = generate_cycles(data)

    local signal_sum = get_signal_sum_1(cycles)
    print('Signal sum: ' .. signal_sum)

    print('\n============\n')
    print('Rendering CRT...\n')
    local crt = { {}, {}, {}, {}, {}, {} }
    for i = 1, 240 do
        local r, c = math.floor((i - 1) / 40) + 1, (i - 1) % 40 + 1
        local char = ''
        if math.abs(cycles[i] - (c - 1)) < 2 then
            char = '#'
        else
            char = '.'
        end
        crt[r][c] = char
    end
    print_crt(crt)
end

main()
