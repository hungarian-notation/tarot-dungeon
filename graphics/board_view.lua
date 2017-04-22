local BACKGROUND_COLOR = { 0x22, 0x22, 0x22 }
local WALL_COLOR = { 0xFF, 0xFF, 0xFF }
local WALL_WIDTH = 5

local gfx = love.graphics

local board_view = {}

board_view.DEFAULT_SCALE = 120

-- |Type:| **BoardExtents**
--
-- Computes the positions of various elements of the board on the screen, given
-- the board's metrics, position, and scale.

local BoardExtents = {} ; board_view.BoardExtents = BoardExtents

function BoardExtents.new(metrics, position, scale)
	local extents = setmetatable({}, BoardExtents)
  
  extents.metrics = metrics
  extents.pos = vector.clone(position or vector(0, 0)) 
  extents.scale = scale or board_view.DEFAULT_SCALE
  
  extents:compute()
  
  return extents
end

function BoardExtents:compute()
  self.col_size = self.scale
  self.row_size = self.scale
  self.board_width = self.col_size * self.metrics.col_count
  self.board_height = self.row_size * self.metrics.row_count
  self.dim = vector(self.board_width, self.board_height)
  self.min = self.pos
  self.max = self.min + self.dim
end

function BoardExtents:get_origin(col, row)
  return vector(
    (col - 1) * self.col_size + self.pos.x,
    (row - 1) * self.row_size + self.pos.y
  )
end

function BoardExtents:get_wall_points(col, row, face)
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

function BoardExtents:__index(key)
  if BoardExtents[key] ~= nil then
    return BoardExtents[key]
  elseif rawget(self.metrics, key) ~= nil then
    return self.metrics[key]
  end
end

--[[

function board_view.get_extents(board_metrics, position, scale)
  assert(type(board_metrics) == 'table', "must supply board metrics")
  
  position  = position or vector(0, 0)
  scale     = scale or board_view.DEFAULT_SCALE
  
  local extents = setmetatable({}, {__index=board_metrics})
  
  extents.scale = scale or board_view.DEFAULT_SCALE
  extents.col_size = extents.scale
  extents.row_size = extents.scale
  extents.board_width = extents.col_size * extents.col_count
  extents.board_height = extents.row_size * extents.row_count
  extents.dim = vector(extents.board_width, extents.board_height)
  extents.pos = vector.clone(position)
  extents.min = extents.pos
  extents.max = extents.min + extents.dim
    
  function extents:get_origin(col, row)
    return vector(
      (col - 1) * extents.col_size + extents.pos.x,
      (row - 1) * extents.row_size + extents.pos.y
    )
  end
  
  function extents:get_wall_points(col, row, face)
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
    
  return extents
end

--]]

function board_view.draw_board(board, extents)
	gfx.setColor(BACKGROUND_COLOR)
  gfx.rectangle("fill", extents.pos.x, extents.pos.y, extents.board_width, extents.board_height)
  
  gfx.setColor(WALL_COLOR)
  gfx.setLineWidth(WALL_WIDTH)
  
  for col = 1, board.metrics.col_count do
    for row = 1, board.metrics.row_count do
      for face = 1, 2 do
        if board:get_wall(col, row, face) then
          local points = extents:get_wall_points(col, row, face)
          gfx.line(points[1].x, points[1].y, points[2].x, points[2].y)
        end
      end
    end
  end
end

return board_view