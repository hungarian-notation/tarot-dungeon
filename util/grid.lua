local Cell = lib.util.cell

-- |Grid| Type

local Grid = {}
; Grid.__index = Grid

-- |Grid::| **new(** ... **)**
--
-- **new(** [Grid] **)** : [Grid]
--    performs a shallow copy of the other grid
--
-- **new(** [Cell] _min_, [Cell] _max_ **)** : [Grid]
--    Creates a grid that spans the rectangle bounded by the specified
--    minimum and maximum cells, inclusive.
--
-- **new(** [number] _columns_, [number] _rows_ **)** : [Grid]
--    Creates a grid that spans the rectangle bounded by (1, 1) and (_columns_, _rows_)
--    inclusive.

function Grid.new(min_or_grid_or_cols, max_or_rows)
  local self = setmetatable({}, Grid)
  
  if getmetatable(min_or_grid_or_cols) == Grid then
    local other = min_or_grid_or_cols
    
    self.min = Cell(other.min)
    self.max = Cell(other.max)
    self.span = self.max - self.min + Cell(1, 1)
    self:clear()
    
    for cell in self:cells() do
      local other_value = other:get(cell)
      if other_value ~= nil then
        self:set(cell, other_value)
      end
    end
  else
    local min, max
    if type(min_or_grid_or_cols) == 'number' and type(max_or_rows) == 'number' then
      min = Cell(1, 1)
      max = Cell(min_or_grid_or_cols, max_or_rows)
    else
      min = Cell(min_or_grid_or_cols)
      max = Cell(max_or_rows)
    end
    
    self.min = min
    self.max = max
    self.span = self.max - self.min + Cell(1, 1)
    self:clear()
  end
    
    return self
end

-- |Grid::| **contains(** [Cell] **)** : [bool]
-- Tests if the grid contains the specified cell.

function Grid:contains(cell)
  assert(type(cell) == 'table', "expected a table for argument #2")
  assert(type(cell.col) == 'number', "expected table at argument #2 to have a 'col' key that is a number")
  assert(type(cell.row) == 'number', "expected table at argument #2 to have a 'row' key that is a number")
  
	return 
    cell.col >= self.min.col and
    cell.row >= self.min.row and
    cell.col <= self.max.col and
    cell.row <= self.max.row
end

-- |Grid::| **clear()** : [nil]
-- Removes all values stored in the grid.

function Grid:clear()
	self._arr = {}
end

-- |Grid::| **get(** [Cell] **)** : [any]
-- Gets the value stored in the grid at the specified cell.

function Grid:get(cell)
  return self._arr[self:_indexof(cell)]
end

-- |Grid::| **set(** [Cell], [any] _value_ **)** : [nil]
-- Stores _value_ in the grid at the specified cell.

function Grid:set(cell, value)
  self._arr[self:_indexof(cell)] = value
end

-- |Grid::| **cells()** : [iterator closure]
-- Returns an iterator across all cells in this grid.

function Grid:cells()
  local col_iter = self.min.col - 1
  local row_iter = self.min.row
  
  return function()
    col_iter = col_iter + 1
    
    if col_iter > self.max.col then 
      col_iter = 1
      row_iter = row_iter + 1
    end
    
    if row_iter <= self.max.row then
      return Cell(col_iter, row_iter)
    end
  end
end

-- |===== Implementation Details =====|

function Grid:_indexof(cell)
  assert(self:contains(cell), "cell not contained in grid")
  local col_index = cell.col - self.min.col
  local row_index = cell.row - self.min.row
  return col_index + row_index * self.span.col + 1
end

return Grid