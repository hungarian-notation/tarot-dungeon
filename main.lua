require "lunar" { global_namespace = true, global_vector = true }
_G['CONFIG'] = require "game_config"

local controller

function love.load(arg)
  math.randomseed(os.time())
  love.window.setMode(1200, 900)
  controller = lib.world.director.Context.create()
end

function love.update(dt)
  
end

function love.keypressed(key, code, is_repeat)
  
  if key == 'left' then
    controller:move_player(-1, 0)
  elseif key == 'right' then
    controller:move_player(1, 0)
  elseif key == 'up' then
    controller:move_player(0, -1)
  elseif key == 'down' then
    controller:move_player(0, 1)
  end
  
  if key == 'space' then
    controller:generate_maze()
  end

end

local gfx = love.graphics

function love.draw()
  lib.graphics.board_view.draw_board(controller.board, controller.board_extents)
  
  local pcenter = controller.board_extents:get_center(controller.player.pos.col, controller.player.pos.row)
  
  gfx.setColor{ 0xFF, 0xFF, 0xFF }
  gfx.circle("fill", pcenter.x, pcenter.y, controller.board_extents.col_size * 0.45, 32) 
end

