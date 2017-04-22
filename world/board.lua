local board = {}

local wall_lib = lib.world.walls

board.DEFAULT_ROW_COUNT = 4
board.DEFAULT_COL_COUNT = 4
board.DEFAULT_SCALE = 120

function board._orient_is_vert(orient)
	local is_vert = orient:sub(1,1):lower() == 'v'
  local is_horiz = orient:sub(1,1):lower() == 'h'
  assert((is_vert and not is_horiz) or (is_horiz and not is_vert))
  return is_vert
end

function board.get_metrics(args)
  if type(args) == 'number' then
    args = { scale=args }
  end
  
  args = args or {}
  
	local metrics = {}
  
  metrics.scale = args.scale or board.DEFAULT_SCALE
  metrics.col_count = args.col_count or board.DEFAULT_COL_COUNT
  metrics.row_count = args.row_count or board.DEFAULT_ROW_COUNT
  metrics.vertical_walls = metrics.col_count - 1
  metrics.horizontal_walls = metrics.row_count - 1
  metrics.col_size = metrics.scale
  metrics.row_size = metrics.scale
  metrics.board_width = metrics.col_size * metrics.col_count
  metrics.board_height = metrics.row_size * metrics.row_count
  metrics.dim = vector(metrics.board_width, metrics.board_height)
  
  function metrics.at_position(pos)
    local metrics = setmetatable({}, {__index=metrics})
    
    metrics.pos = vector.clone(pos)
    metrics.min = metrics.pos
    metrics.max = metrics.min + metrics.dim
    
    function metrics:get_origin(col, row)
    	return vector(
        (col - 1) * metrics.col_size + metrics.pos.x,
        (row - 1) * metrics.row_size + metrics.pos.y
      )
    end
    
    function metrics:get_wall_points(col, row, face)
    	if face == 1 then
        return { 
          self:get_origin(col+1, row), 
          self:get_origin(col+1, row+1)
        }
      elseif face == 2 then
        return {
          self:get_origin(col, row+1),
          self:get_origin(col+1, row+1)
        }
      elseif face == 3 then
        return {
          self:get_origin(col, row),
          self:get_origin(col, row+1)
        }
      elseif face == 4 then
        return {
          self:get_origin(col, row),
          self:get_origin(col+1, row)
        }
      else error("face must be 1, 2, 3, or 4")
      end
    end
    
    return metrics
  end
  
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
  self._walls = wall_lib.Walls.new { cols = self.metrics.col_count, rows = self.metrics.row_count }
end

function BoardState:get_wall(...)
	return self._walls:get_wall(...)
end

function BoardState:set_wall(...)
	return self._walls:set_wall(...)
end

function BoardState:get_walls()
	return self._walls:clone()
end

function BoardState:set_walls(walls)
  self._walls = walls:clone()
end

function BoardState:has_wall(...)
	return self._walls:has_wall(...)
end

return board