local lyaml = require 'lyaml'

local args = { ... }

local function get_operation(op_str)
    if op_str == nil then return 'no_func' end
    local var1, op, var2 = op_str:match('(%l+) ([%*%+]) (%w+)')
    assert(var1 == 'old')

    local func = function() end
    if op == '+' and var2 ~= 'old' then
        func = function(x) return x + tonumber(var2) end
    elseif op == '+' and var2 == 'old' then
        func = function(x) return x + x end
    elseif op == '*' and var2 ~= 'old' then
        func = function(x) return x * tonumber(var2) end
    elseif op == '*' and var2 == 'old' then
        func = function(x) return x * x end
    else
        error('Unrecognized operator ' .. op)
    end
    return func
end

-- Meta class
Monkey = { name = '', items = {}, op_str = '', test = nil, if_true = nil,
    if_false = nil, count = 0 }

-- Derived class method new
function Monkey:new(o, name, items, op_str, test, if_true, if_false, count)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.name = name or 'default'
    self.items = items or {}
    self.op_str = op_str or ''
    self.test = test or nil
    self.if_true = if_true or nil
    self.if_false = if_false or nil
    self.count = count or 0
    return o
end

function Monkey:add_operation()
    local func = get_operation(self.op_str)
    self.operation = func
end

local function file_exists(file_path)
    local f = io.open(file_path, 'rb')
    if f then f:close() end
    return f ~= nil
end

local function read_file(file_path)
    if not file_exists(file_path) then return {} end
    io.input(file_path)
    local data = io.read('*all')
    return data
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

local function gen_monkeys(data)
    local monkeys = {}
    local names = {}
    local divs = {}

    print('Generating monkeys...')
    for name, tbl in pairs(data) do
        print('Adding ' .. name)
        table.insert(names, name)
        local monkey = Monkey:new { name = name, items = tbl['items'],
            op_str = tbl['operation'], test = tbl['test'], if_true = tbl['if_true'],
            if_false = tbl['if_false'] }
        monkey:add_operation()
        monkeys[name] = monkey
        table.insert(divs, tbl['test'])
    end
    print('')

    table.sort(names)
    local divisor = 1
    for _, v in ipairs(divs) do
        divisor = divisor * v
    end
    return names, monkeys, divisor
end

local function get_monkey_business(monkeys)
    local counts = {}
    for n, obj in pairs(monkeys) do
        print(n .. ' inspected items ' .. obj.count .. ' times')
        table.insert(counts, obj.count)
    end
    table.sort(counts, function(x, y) return x > y end)
    return counts[1] * counts[2]
end

local function main()
    local input_name, rounds = args[1], args[2]
    if input_name == nil then
        print('No input file was provided.')
        return
    end

    local data_str = read_file(input_name)
    local data = lyaml.load(data_str)

    local names, monkeys, divisor = gen_monkeys(data)

    print('Commencing simulation...')
    for round = 1, rounds do
        io.write('Round ' .. round .. '/' .. rounds .. ' --- ')
        for _, name in ipairs(names) do
            for _ = 1, #monkeys[name].items do
                local item = table.remove(monkeys[name].items, 1)

                if rounds == 20 then
                    item = math.floor(monkeys[name].operation(item) / 3)
                else
                    item = monkeys[name].operation(item % divisor)
                end

                local if_true, if_false = monkeys[name].if_true, monkeys[name].if_false
                if item % monkeys[name].test == 0 then
                    table.insert(monkeys['monkey' .. if_true].items, item)
                else
                    table.insert(monkeys['monkey' .. if_false].items, item)
                end
                monkeys[name].count = monkeys[name].count + 1
            end
        end
        io.write('Done\n')
    end
    print('')

    local monkey_business = get_monkey_business(monkeys)
    print('Monkey business: ' .. monkey_business)
end

main()
