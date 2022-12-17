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

local function inspect_table(data)
  local n = 3

  print('\nFirst ' .. n .. ' elements')
  for i = 1, 3, 1 do
    print(data[i])
  end

  print('Last ' .. n .. ' elements')
  for i = #data, #data - n + 1, -1 do
    print(data[i])
  end

  print('The table has ' .. #data .. ' elements')
end

local function split_line(line)
  -- assumes a line of the form "A X"
  return line:sub(1, 1), line:sub(3, 3)
end

local function map_letter(letter)
  local opponend_map = { A = 'Rock', B = 'Paper', C = 'Scissors' }
  local you_map = { X = 'lose', Y = 'draw', Z = 'win' }

  if opponend_map[letter] ~= nil then
    return opponend_map[letter]
  elseif you_map[letter] ~= nil then
    return you_map[letter]
  else
    error('Unknown letter ' .. letter .. ' occured')
  end
end

local function get_right_shape(opponend, you)
  local right_shape_map = {
    lose = { Rock = 'Scissors', Paper = 'Rock', Scissors = 'Paper' },
    draw = { Rock = 'Rock', Paper = 'Paper', Scissors = 'Scissors' },
    win = { Rock = 'Paper', Paper = 'Scissors', Scissors = 'Rock' }
  }
  return right_shape_map[you][opponend]
end

local function get_shape_score(you)
  if you == 'Rock' then
    return 1
  elseif you == 'Paper' then
    return 2
  elseif you == 'Scissors' then
    return 3
  else
    error('Invalid shape ' .. you)
  end
end

local function get_match_score(opponend, you)
  if opponend == you then
    return 3
  elseif opponend == 'Rock' and you == 'Paper' then
    return 6
  elseif opponend == 'Rock' and you == 'Scissors' then
    return 0
  elseif opponend == 'Paper' and you == 'Rock' then
    return 0
  elseif opponend == 'Paper' and you == 'Scissors' then
    return 6
  elseif opponend == 'Scissors' and you == 'Rock' then
    return 6
  elseif opponend == 'Scissors' and you == 'Paper' then
    return 0
  else
    error('Unknown match combination ' .. opponend .. ' ' .. you)
  end
end

local function get_end_score(trials)
  local end_score = 0
  for _, l in pairs(trials) do
    local o_letter, y_letter = split_line(l)
    local o_shape, y_strategy = map_letter(o_letter), map_letter(y_letter)
    local y_shape = get_right_shape(o_shape, y_strategy)
    local match_score = get_match_score(o_shape, y_shape)
    local y_shape_score = get_shape_score(y_shape)

    end_score = end_score + match_score
    end_score = end_score + y_shape_score
  end
  return end_score
end

local function main()
  local file_name = args[1]
  print('Data used: "' .. file_name .. '"')

  local trials = lines_from(file_name)
  inspect_table(trials)

  print(' ')
  local end_score = get_end_score(trials)
  print('You will get ' .. end_score .. ' points')
end

main()
