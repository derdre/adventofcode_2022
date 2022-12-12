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

local function table_contains(tbl, key)
    return tbl[key] ~= nil
end

local function get_line_type(line)
    if line:sub(1, 2) == '$ ' then
        return 'command'
    elseif type(tonumber(line:sub(1, 1))) == 'number' then
        return 'file'
    elseif line:sub(1, 3) == 'dir' then
        return 'dir'
    else
        error('Unknown line type: ' .. line)
    end
end

local function dir_to_str(current_dir)
    local out = ''
    for _, path in ipairs(current_dir) do
        out = out .. '/' .. path
    end
    return out
end

local function split_file(line)
    local size, name = line:match('(%d+) ([%l%.]+)')
    return name, size
end

local function split_command(line)
    local cmd, path = line:match('%$ (%l%l)[ ]?([%l%.%/]*)')
    return cmd, path
end

local function split_dir(line)
    local dir_name = line:match('dir (%l+)')
    return dir_name
end

local function test_all_files_found(data, file_sizes)
    for _, l in ipairs(data) do
        if l:match('%d+') then -- line starts with digits
            local size, name = l:match('(%d+) ([%l%.]+)')
            print(size, name, file_sizes[name])
            assert(tonumber(size) == file_sizes[name], 'File not found! ' .. name)
        end
    end
end

local function mod_current_dir(current_dir, path)
    if path == '..' then
        table.remove(current_dir)
    else
        table.insert(current_dir, path)
    end
    return current_dir
end

local function get_dir_size(dir_tbl, file_sizes, dir_tree, acc)
    if acc == nil then acc = 0 end
    for _, obj in ipairs(dir_tbl) do
        if obj['file'] ~= nil then
            acc = acc + file_sizes[obj['file']]
        elseif obj['dir'] ~= nil then
            acc = get_dir_size(dir_tree[obj['dir']], file_sizes, dir_tree, acc)
        else
            error('Unknown state reached!')
        end
    end
    return acc
end

local function get_smallest_folder(dir_sizes)
    local min_needed_size = 8381165
    local folder_sizes = {}
    for _, v in pairs(dir_sizes) do
        if v > min_needed_size then
            table.insert(folder_sizes, v)
        end
    end

    table.sort(folder_sizes)

    return folder_sizes[1]
end

local function main()
    local input_name = args[1]
    if input_name == nil then
        print('No input file was provided.')
        return
    end

    local data = lines_from(input_name)
    local file_sizes = {}
    local dir_tree = {}
    local dir_sizes = {}
    local current_dir = {}
    local is_listing = false

    for i = 1, #data do
        local line = data[i]
        local line_type = get_line_type(line)

        if line_type ~= 'command' and is_listing then
            if not table_contains(dir_tree, dir_to_str(current_dir)) then
                dir_tree[dir_to_str(current_dir)] = {}
            end
            if line_type == 'file' then
                local file_name, size = split_file(line)
                local file_path = dir_to_str(current_dir) .. '/' .. file_name
                file_sizes[file_path] = tonumber(size)
                local file_tbl = {}
                file_tbl['file'] = file_path
                table.insert(dir_tree[dir_to_str(current_dir)], file_tbl)
                print('Added file ' ..
                    file_path .. ' with size ' .. file_sizes[file_path])
            elseif line_type == 'dir' then
                local dir_name = split_dir(line)
                local dir_tbl = {}
                dir_tbl['dir'] = dir_to_str(current_dir) .. '/' .. dir_name
                table.insert(dir_tree[dir_to_str(current_dir)], dir_tbl)
                print('Added dir ' .. dir_tbl['dir'])
            end

        elseif line_type == 'command' then
            local cmd, path = split_command(line)
            if cmd == 'ls' then
                is_listing = true
            elseif cmd == 'cd' then
                is_listing = false
                current_dir = mod_current_dir(current_dir, path)
            else
                error('Unknown command: ' .. cmd)
            end
        end
    end

    print('\n----------\n')

    for dir_name, v in pairs(dir_tree) do
        local dir_size = get_dir_size(v, file_sizes, dir_tree)
        print('Computing size for dir ' .. dir_name .. ' ' .. dir_size)
        dir_sizes[dir_name] = dir_size
    end

    print('\n----------\n')
    local small_sum = 0
    for k, v in pairs(dir_sizes) do
        if v <= 100000 then
            print('Relevant dir ' .. k .. ' with size ' .. v)
            small_sum = small_sum + v
        end
    end

    print('\n----------\n')
    print('Total size of small folders ' .. small_sum)

    print('\n----------\n')
    local smallest_folder_size = get_smallest_folder(dir_sizes)
    print('The folder to delete has a size of ' .. smallest_folder_size)

end

main()
