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

local function count_calories(table_snacks)
  local cal_packs = {}
  local cal_pack = 0

  for _, snack in ipairs(table_snacks) do
    if snack ~= '' then
      cal_pack = cal_pack + tonumber(snack)
    else
      cal_packs[#cal_packs + 1] = cal_pack
      cal_pack = 0
    end
  end

  return cal_packs
end

local function sum_last_n(table_packs, amount)
  table.sort(table_packs)
  local last_n_sum = 0

  for n = #table_packs, #table_packs - amount + 1, -1 do
    last_n_sum = last_n_sum + table_packs[n]
  end

  return last_n_sum
end

local function main()
  local file_path = args[1]
  print('Data used: "' .. file_path .. '"')

  local table_snacks = lines_from(file_path)
  local cal_packs = count_calories(table_snacks)

  print('The elve carrying the most calories has ' .. math.max(table.unpack(cal_packs)))
  print('The 3 most packed elves carry ' .. sum_last_n(cal_packs, 3) .. ' calories')

end

main()
