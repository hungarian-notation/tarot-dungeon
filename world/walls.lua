local wall_lib = {}

local NORTH = 4
local SOUTH = 2
local EAST = 1
local WEST = 3

-- |Utility Functions|

function wall_lib.normalize(col, row, face)
  if face == 1 or face == 2 then
    return col, row, face
  elseif face == 3 then
    return col - 1, row, 1
  elseif face == 4 then
    return col, row - 1, 2
  else
    error("face must be 1, 2, 3, or 4")
  end
end

function wall_lib.direction(from_cell, to_cell)
  local diff = { 
    col = to_cell.col - from_cell.col,
    row = to_cell.row - from_cell.row
  }
  
  if diff.col == 1 and diff.row == 0 then
    return EAST
  elseif diff.col == 0 and diff.row == 1 then
    return SOUTH
  elseif diff.col == -1 and diff.row == 0 then
    return WEST
  elseif diff.col == 0 and diff.row == -1 then
    return NORTH
  else
    return nil
  end
end

-- |Type:| **Walls**
-- 
-- Maintains the state of the walls between cells in a grid. This type
-- allows for the manipulation of the walls between cells only. Walls at
-- the border may not be manipulated, and `get_walls` returns nil for those
-- walls.

local Walls = {} ; Walls.__index = Walls ; wall_lib.Walls = Walls

function Walls.new(args)
  args.row_count = args.row_count or args.rows
  args.col_count = args.col_count or args.cols
  
  assert(type(args.row_count) == 'number', "missing [number] row_count")
  assert(type(args.col_count) == 'number', "missing [number] col_count")
  
  local obj = setmetatable({}, Walls)
  
  obj.row_count = args.row_count
  obj.col_count = args.col_count
  obj:clear_walls()
  
  return obj
end

function Walls:clone()
  local cloned = Walls.new { col_count = self.col_count, row_count = self.row_count }
  for col = 1, self.col_count do
    for row = 1, self.row_count do
      for face = 1, 2 do
        if self:has_wall(col, row, face) then
          cloned:set_wall(col, row, face, self:get_wall(col, row, face))
        end
      end
    end
  end
  return cloned
end

function Walls:clear_walls()
	self._arr = {}
  local arr = self._arr
  for col = 1, self.col_count do
    arr[col] = {}
    for row = 1, self.row_count do
        arr[col][row] = {false, false}
    end
  end
end

function Walls:has_wall(col, row, face)
	col, row, face = wall_lib.normalize(col, row, face)
  
  if col < 1 or row < 1 then
    return false
  elseif col > self.col_count or row > self.row_count then
    return false
  elseif col == self.col_count and face == 1 then
    return false
  elseif row == self.row_count and face == 2 then
    return false
  else 
    return true
  end
end

function Walls:set_wall(col, row, face, state)
	col, row, face = wall_lib.normalize(col, row, face)
  
  if self:has_wall(col, row, face) then
    self._arr[col][row][face] = state
  else
    error("wall out of bounds: face #" .. face .. " of cell " .. col .. ", " .. row)
  end
end

function Walls:get_wall(col, row, face)
	col, row, face = wall_lib.normalize(col, row, face)
  
  if self:has_wall(col, row, face) then
    return self._arr[col][row][face]
  else
    return nil
  end
end

return wall_lib