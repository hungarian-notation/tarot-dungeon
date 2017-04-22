local director = {}

local Context = {} 
; Context.__index   = Context 
; director.Context  = Context

function Context.create()
	
  local self = setmetatable({}, Context)
  
  self.board = lib.world.board.BoardState.new {
    col_count = CONFIG.BOARD.COL_COUNT,
    row_count = CONFIG.BOARD.ROW_COUNT
  }
  
  self.board_extents = lib
    .graphics
    .board_view
    .get_extents( 
      self.board.metrics, 
      vector(0, 0), 
      CONFIG.BOARD.SCALE 
    )
  
  self.player = { 
    pos = { 
      col = math.ceil(CONFIG.BOARD.COL_COUNT / 2), 
      row = math.ceil(CONFIG.BOARD.ROW_COUNT / 2) 
    } 
  }
  
  self:generate_maze()
  
  return self
  
end

function Context:generate_maze()
	local maze = lib.world.mazes.generate_maze {
    col_count = self.board.metrics.col_count,
    row_count = self.board.metrics.row_count,
    wall_goal = self.board.metrics.col_count *
      self.board.metrics.row_count * CONFIG.BOARD.WALL_DENSITY
  }
  lib.world.mazes.cull_loose_walls(maze)
  self.board:set_walls(maze)
end

function Context:move_player(cdiff, rdiff)
  local from = self.player.pos
  local to = { 
    col=self.player.pos.col + cdiff, 
    row=self.player.pos.row + rdiff 
  }
  
  local move_dir = lib.world.walls.direction(from, to)
  
  local walls = self.board:get_walls()
  
  if walls:has_wall(from.col, from.row, move_dir) then
    if walls:get_wall(from.col, from.row, move_dir) == false then
      self.player.pos = to
    end
  end
end

return director