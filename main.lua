require "lunar" { global_namespace = true, global_vector = true }

local board
local board_extents

local player_pos = { col = 1, row = 1 }

function love.load(arg)
  math.randomseed(os.time())
  
  love.window.setMode(1200, 900)
  
  board = lib.world.board.BoardState.new { col_count = 8, row_count = 8 }
  
  board:set_walls(
    lib.world.mazes.generate_maze {
      col_count = board.metrics.col_count, 
      row_count = board.metrics.row_count, 
      wall_goal = board.metrics.col_count * board.metrics.row_count * 0.65
    })
  
  lib.world.mazes.cull_loose_walls(board.walls)
  
  board_extents = lib.graphics.board_view.get_extents(board.metrics, nil, 900/board.metrics.row_count)
end

function love.update(dt)
  
end

local function move_player(cdiff, rdiff)
  
  local from = player_pos
  local to = { col=player_pos.col + cdiff, row=player_pos.row + rdiff }
  local move_dir = lib.world.walls.direction(from, to)
  
  local walls = board:get_walls()
  
  if walls:has_wall(from.col, from.row, move_dir) then
    if walls:get_wall(from.col, from.row, move_dir) == false then
      player_pos = to
    end
  end
end

function love.keypressed(key, code, is_repeat)
  
  if key == 'left' then
    move_player(-1, 0)
  elseif key == 'right' then
    move_player(1, 0)
  elseif key == 'up' then
    move_player(0, -1)
  elseif key == 'down' then
    move_player(0, 1)
  end

end

local gfx = love.graphics

function love.draw()
  lib.graphics.board_view.draw_board(board, board_extents)
  
  local pcenter = board_extents:get_center(player_pos.col, player_pos.row)
  
  gfx.setColor{ 0xFF, 0xFF, 0xFF }
  gfx.circle("fill", pcenter.x, pcenter.y, board_extents.col_size * 0.45, 32) 
end

