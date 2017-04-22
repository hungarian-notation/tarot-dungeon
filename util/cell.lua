local Cell = {}
; Cell.__index = Cell
; setmetatable(Cell, { __call = function (table, ...) return Cell.new(...) end })

function Cell.new(...)
	local self = setmetatable({}, Cell)
  self:set(...)
  return self
end

function Cell:set(col_or_coord, row_or_nil)
  if type(col_or_coord) == 'table' then
    self.col = col_or_coord.col or col_or_coord.x
    self.row = col_or_coord.row or col_or_coord.y
  else
    self.col = col_or_coord
    self.row = row_or_nil
  end
  
  assert(type(self.col) == 'number', "column must be a number")
  assert(type(self.row) == 'number', "row must be a number")
  
  return self
end

function Cell:__tostring()
	return "(" .. self.col .. ", " .. self.row .. ")"
end

function Cell.__add(a, b)
	return Cell.new(a.col + b.col, a.row + b.row)
end

function Cell.__sub(a, b)
	return Cell.new(a.col - b.col, a.row - b.row)
end

function Cell.__eq(a, b)
  return a.col == b.col and a.row == b.row
end

-- row-major comparison

function Cell.__lt()
  return a.row < b.row or (a.row == b.row and a.col < b.col)
end

function Cell.__le()
  return a.row < b.row or (a.row == b.row and a.col <= b.col)
end

return Cell