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

local def_cell = lib.world.cell.create

function wall_lib.get_junctions(col, row, face)
  if face == 1 then
    return { 
      def_cell(col+1, row), 
      def_cell(col+1, row+1)
    }
  elseif face == 2 then
    return {
      def_cell(col, row+1),
      def_cell(col+1, row+1)
    }
  elseif face == 3 then
    return {
      def_cell(col, row),
      def_cell(col, row+1)
    }
  elseif face == 4 then
    return {
      def_cell(col, row),
      def_cell(col+1, row)
    }
  else error("face must be 1, 2, 3, or 4")
  end
end

-- |Type:| **Walls**
-- 
-- Maintains the state of the walls between cells in a grid. This type
-- allows for the manipulation of the walls between cells only. Walls at
-- the border may not be manipulated, and `get_walls` returns nil for those
-- walls.

local WallGrid = {} ; WallGrid.__index = WallGrid ; wall_lib.WallGrid = WallGrid

function WallGrid.new(args)
  args.row_count = args.row_count or args.rows
  args.col_count = args.col_count or args.cols
  
  assert(type(args.row_count) == 'number', "missing [number] row_count")
  assert(type(args.col_count) == 'number', "missing [number] col_count")
  
  local obj = setmetatable({}, WallGrid)
  
  obj.row_count = args.row_count
  obj.col_count = args.col_count
  obj:clear_walls()
  
  return obj
end

function WallGrid:clone()
  local cloned = WallGrid.new { col_count = self.col_count, row_count = self.row_count }
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

function WallGrid:clear_walls()
	self._arr = {}
  local arr = self._arr
  for col = 1, self.col_count do
    arr[col] = {}
    for row = 1, self.row_count do
        arr[col][row] = {false, false}
    end
  end
end

-- _Walls::_ **count_junction**
-- Counts the number of walls that intersect at the origin of a cell.

function WallGrid:count_junction(col, row)
  local count = 0
  
  if self:get_wall(col, row, 3) then count = count + 1 end
  if self:get_wall(col, row, 4) then count = count + 1 end
  if self:get_wall(col - 1, row - 1, 1) then count = count + 1 end
  if self:get_wall(col - 1, row - 1, 2) then count = count + 1 end
  
  return count
end

-- _Walls::_ **is_loose**
-- Tests if the specified wall is loose; i.e. not connected to any other wall.

function WallGrid:is_loose(col, row, face)
  if not self:get_wall(col, row, face) then
    error("no wall in that position")
  else
    local junctions = wall_lib.get_junctions(col, row, face)
    local left = self:count_junction(junctions[1].col, junctions[1].row)
    local right = self:count_junction(junctions[2].col, junctions[2].row)
    return left == 1 and right == 1
  end
end

function WallGrid:has_cell(...)
  local cell = def_cell(...)
  
	return 
    cell.col >= 1 and cell.col <= self.col_count and
    cell.row >= 1 and cell.row <= self.row_count
end

function WallGrid:has_wall(col, row, face)
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

function WallGrid:set_wall(col, row, face, state)
	col, row, face = wall_lib.normalize(col, row, face)
  
  if self:has_wall(col, row, face) then
    self._arr[col][row][face] = state
  else
    error("wall out of bounds: face #" .. face .. " of cell " .. col .. ", " .. row)
  end
end

function WallGrid:get_wall(col, row, face)
	col, row, face = wall_lib.normalize(col, row, face)
  
  if self:has_wall(col, row, face) then
    return self._arr[col][row][face]
  else
    return nil
  end
end

function WallGrid:is_passable(col, row, face)
	return self:get_wall(col, row, face) == false
end

function WallGrid:get_connected_cells(col, row)
	local cells = {}
  local origin_cell = def_cell(col, row)
  
  local function try(cdiff, rdiff)
    local adjacent_cell = def_cell(col+cdiff, row+rdiff)
    local dir = wall_lib.direction(origin_cell, adjacent_cell)
    
    if self:is_passable(origin_cell.col, origin_cell.row, dir) then
      table.insert(cells, adjacent_cell)
    end
  end
  
  try(1, 0) ; try(-1, 0) ; try(0, 1) ; try(0, -1)

  return cells
end

function WallGrid:cells()
	local col = 0
  local row = 1
  
  local col_max = self.col_count
  local row_max = self.row_count
  
  return function()
    col = col + 1
    
    if col > col_max then 
      col = 1
      row = row + 1
    end
    
    if row <= row_max then
      return def_cell(col, row)
    end
  end
end

return wall_lib