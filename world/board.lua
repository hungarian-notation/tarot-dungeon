

local board = {}
local wall_lib = lib.world.walls

board.DEFAULT_ROW_COUNT = 4
board.DEFAULT_COL_COUNT = 4

--[[

function board._orient_is_vert(orient)
	local is_vert = orient:sub(1,1):lower() == 'v'
  local is_horiz = orient:sub(1,1):lower() == 'h'
  assert((is_vert and not is_horiz) or (is_horiz and not is_vert))
  return is_vert
end

--]]

-- |Utility Functions|

function board.get_metrics(args)
  if type(args) == 'number' then
    args = { scale=args }
  end
  
  args = args or {}
  
	local metrics = {}
  
  metrics.col_count = args.col_count or board.DEFAULT_COL_COUNT
  metrics.row_count = args.row_count or board.DEFAULT_ROW_COUNT
  metrics.vertical_walls = metrics.col_count - 1
  metrics.horizontal_walls = metrics.row_count - 1
  
  return metrics
end

local BoardState = {} ; BoardState.__index = BoardState
board.BoardState = BoardState

function BoardState.new(args)
	local state = setmetatable({}, BoardState)
  
  state.metrics = board.get_metrics(args)
  
  state:clear_cells()
  state:clear_walls()
  
  return state
end

function BoardState:clear_cells()
  self.cells = {}
  
  for col = 1, self.metrics.col_count do
    self.cells[col] = {}
    for row = 1, self.metrics.row_count do
      self.cells[col][row] = { cell_type = 'normal' }
    end
  end
end

function BoardState:clear_walls()
  self.walls = wall_lib.Walls.new { cols = self.metrics.col_count, rows = self.metrics.row_count }
end

function BoardState:get_wall(...)
	return self.walls:get_wall(...)
end

function BoardState:set_wall(...)
	return self.walls:set_wall(...)
end

function BoardState:get_walls()
	return self.walls:clone()
end

function BoardState:set_walls(walls)
  self.walls = walls:clone()
end

function BoardState:has_wall(...)
	return self.walls:has_wall(...)
end

return board