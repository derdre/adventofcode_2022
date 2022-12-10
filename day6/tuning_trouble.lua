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

local function is_unique(data)
    local buf = ''
    for s in data:gmatch('.') do
        if not buf:find(s) then
            buf = buf .. s
        else
            return false
        end
    end
    return true
end

local function main()
    local file_name, window = args[1], args[2]
    if file_name == nil then
        print('No input file was provided.')
        return
    end

    local data = lines_from(file_name)[1]

    for i = 1, #data do
        local substring = data:sub(i, i + window - 1)
        -- print(i, substring, is_unique(substring))
        if is_unique(substring) then
            print(
                'First unique substring (' .. window .. ') at '
                .. i .. '(' .. i + window - 1 .. ') '
                .. substring)
            break
        end
    end
end

main()
