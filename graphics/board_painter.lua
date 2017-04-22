local BACKGROUND_COLOR = { 0x22, 0x22, 0x22 }
local WALL_COLOR = { 0xFF, 0xFF, 0xFF }
local WALL_WIDTH = 5

local gfx = love.graphics

return function(board, pos)
  local metrics = board.metrics.at_position(pos or vector.zero())

  gfx.setColor(BACKGROUND_COLOR)
  gfx.rectangle("fill", metrics.pos.x, metrics.pos.y, metrics.board_width, metrics.board_height)
  
  gfx.setColor(WALL_COLOR)
  gfx.setLineWidth(WALL_WIDTH)
  
  for col = 1, board.metrics.col_count do
    for row = 1, board.metrics.row_count do
      for face = 1, 2 do
        if board:get_wall(col, row, face) then
          local points = metrics:get_wall_points(col, row, face)
          gfx.line(points[1].x, points[1].y, points[2].x, points[2].y)
        end
      end
    end
  end
  
end