local wall_lib = lib.world.walls

local maze_lib = {}

-- |Function:| **is_passable**
-- 
-- This function attempts to flood fill a walls grid. It returns true if it can
-- reach every cell from its starting cell.

function maze_lib.is_passable(walls)
  local visits = 0
  local visited = {}
  local stack = {}

  
  local function is_cell(cell)
    return cell.col >= 1 and cell.col <= walls.col_count
      and cell.row >= 1 and cell.row <= walls.row_count
  end
  
  local function has_vistited(cell)
    return visited[cell.col] and visited[cell.col][cell.row]
  end
  
  local function push(cell)    
    if is_cell(cell) then
      table.insert(stack, cell)
    end
  end
  
  local function try_push(cell, col_diff, row_diff)
    local cell_to = { col = cell.col + col_diff, row = cell.row + row_diff }
    
    if is_cell(cell_to) then
      local face = wall_lib.direction(cell, cell_to)
      
      assert(face)
      assert(walls:has_wall(cell.col, cell.row, face), 
        "there should be a wall here: (" .. tostring(cell_to.col) .. ", " .. tostring(cell_to.row) .. ")")
      
      local passable = walls:has_wall(cell.col, cell.row, face) 
        and not walls:get_wall(cell.col, cell.row, face)
        
      if passable then 
        push(cell_to)
      end
    end
  end
  
  push { col = 1, row = 1 }
  
  while #stack > 0 do
    local next_cell = table.remove(stack)
        
    if not has_vistited(next_cell) then
      visits = visits + 1
      visited[next_cell.col] = visited[next_cell.col] or {}
      visited[next_cell.col][next_cell.row] = true
      try_push( next_cell,  1,  0 )
      try_push( next_cell,  0,  1 )
      try_push( next_cell, -1,  0 )
      try_push( next_cell,  0, -1 )
    end
  end
  
  return visits == walls.col_count * walls.row_count
end

-- |Function:| **generate_maze**
-- 
-- A (stupid) naeive maze generation algorithm. It's guess and check! With flood fill! 
-- Exponential complexity! Like, third order exponential!

local COLLISION_FACTOR = 10

function maze_lib.generate_maze(args, opt_walls)
  
  local wall_grid = opt_walls or 
    wall_lib.WallGrid.new { col_count = args.col_count, row_count = args.row_count }
  
  local working_walls = wall_grid:clone()
  local predicate = args.predicate or function() return true end
  
  assert(lib.world.mazes.is_passable(wall_grid))
  
  local placed = 0
  local collisions = 0
  
  while placed < args.wall_goal and collisions < args.wall_goal do
    local set = false
    
    local col = math.random(1, args.col_count)
    local row = math.random(1, args.row_count)
    local face = math.random(1, 4)
    
    if working_walls:has_wall(col, row, face) and not working_walls:get_wall(col, row, face) then
      working_walls:set_wall(col, row, face, true)
      
      if lib.world.mazes.is_passable(working_walls) and predicate(working_walls, col, row, face) then
        set = true
        placed = placed + 1
        wall_grid = working_walls:clone()
      else
        collisions = collisions + 1
        working_walls = wall_grid:clone()
      end
    end
  end
  
  return wall_grid
end


-- |Function:| **cull_loose_walls**
-- Removes walls that do not connect to any other wall.

function maze_lib.cull_loose_walls(wall_set)
  for col = 1, wall_set.col_count do
    for row = 1, wall_set.row_count do
      for face = 1, 2 do
        if wall_set:get_wall(col, row, face) and wall_set:is_loose(col, row, face) then
          wall_set:set_wall(col, row, face, false)
        end
      end        
    end
  end
end

-- |Function:| **find_path**
-- Finds a path between two cells

function maze_lib.find_path(walls, from_cell, to_cell)
	
  local vertices_Q = {}
  local graph = {}
  
  for cell in walls:cells() do 
    graph[cell.col] = graph[cell.col] or {}
    
    graph[cell.col][cell.row] = { 
      dist = math.huge,
      prev = nil
    }
    
    table.insert(vertices_Q, cell)
  end
  
  
  local function candidate(cell, distance) 
    
  end
  
end

return maze_lib