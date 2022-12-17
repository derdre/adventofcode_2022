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

local function priorities()
  local start_upper_case = 65
  local start_lower_case = 97
  local prio_map = {}
  for i = 1, 26 do
    -- lower case
    prio_map[string.char(start_lower_case + i - 1)] = i
    -- upper case
    prio_map[string.char(start_upper_case + i - 1)] = i + 26
  end
  -- tprint(prio_map)
  return prio_map
end

local function get_triple(rucksacks, i)
  if i == nil then i = 1 end
  return rucksacks[i], rucksacks[i + 1], rucksacks[i + 2]
end

local function find_tripple_letter(rucksack1, rucksack2, rucksack3)
  local double_letters = {}
  for i = 1, #rucksack1 do
    local double_letter = rucksack1:sub(i, i)
    if rucksack2:find(double_letter) then
      double_letters[#double_letters + 1] = double_letter
    end
  end
  for _, l in ipairs(double_letters) do
    if rucksack3:find(l) then
      return l
    end
  end
  error('No letter match found')
end

local function main()
  local file_name = args[1]
  print('Data used: "' .. file_name .. '"')

  local rucksacks = lines_from(file_name)
  local prio_map = priorities()
  local sum_prio = 0

  for i = 1, #rucksacks, 3 do
    local rucksack1, rucksack2, rucksack3 = get_triple(rucksacks, i)
    local tripple_letter = find_tripple_letter(rucksack1, rucksack2, rucksack3)
    local letter_score = prio_map[tripple_letter]
    sum_prio = sum_prio + letter_score
  end
  print('Sum priorities: ' .. tostring(sum_prio))

end

main()
