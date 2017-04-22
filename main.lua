require "lunar" { global_namespace = true, global_vector = true }

local board

function love.load(arg)
  math.randomseed(os.time())
  
  love.window.setMode(1200, 900)
  
  board = lib.world.board.BoardState.new { col_count = 4, row_count = 4 }
  
  --[[
  local walls = board:get_walls()
  
  assert(lib.world.mazes.is_passable(walls))
  
  for i = 1, 7 do
    local set = false
    local working_walls = walls:clone()
    
    while not set do
      assert(lib.world.mazes.is_passable(working_walls))
      
      local c = math.random(1, board.metrics.col_count)
      local r = math.random(1, board.metrics.row_count)
      local f = math.random(1, 4)
      
      if working_walls:has_wall(c, r, f) and not working_walls:get_wall(c, r, f) then
        working_walls:set_wall(c, r, f, true)
        
        if lib.world.mazes.is_passable(working_walls) then
          set = true
          walls = working_walls
        else
          working_walls = walls:clone()
        end
      end
    end
  end
  --]]
  
  board:set_walls(
    lib.world.mazes.generate_maze {
      col_count = board.metrics.col_count, 
      row_count = board.metrics.row_count, 
      wall_goal = board.metrics.col_count * board.metrics.row_count })
end

function love.update(dt)
  
end

function love.keypressed(key, code, is_repeat)
  
end

function love.draw()
  local extents = lib.graphics.board_view.BoardExtents.new(board.metrics, nil, 900/4)
  
  lib.graphics.board_view.draw_board(board, extents)
end

