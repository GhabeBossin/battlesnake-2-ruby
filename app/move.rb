# TODO: Implement your logic here!
# View docs at https://docs.battlesnake.com/snake-api for example payloads.

# This is used to output all the data for our snake, Letty.
# Add needed letty info here, access it by calling method.
def readable_letty_data(data)
  letty = data[:you]
  letty_body = letty[:body]
  letty_data = {
    snek: letty,
    health: letty[:health],
    body: letty_body,
    head: letty_body.first,
    head_x: letty_body.first[:x],
    head_y: letty_body.first[:y],
    tail: letty_body.last,
    tail_x: letty_body.last[:x],
    tail_y: letty_body.last[:y]
  }
  return letty_data
end

# This is used to output all the game data that isn't our snake.
# Add needed game data here, access it by calling method.
def readable_board_data(data)
  board = data[:board]
  board_data = {
    board: board,
    width: board[:width],
    height: board[:height],
    food: board[:food],
    snakes: board[:snakes]
  }
  return board_data
end

def move(data)
  letty = readable_letty_data(data)
  directions = [:up, :down, :left, :right]
  safe_directions = avoid_obstacles(data, directions)
  move = safe_directions.sample

  if (letty[:health] >= 85)
    move = chase_tail(data, safe_directions).sample
    { move: move }
  else
    { move: move }
  end
end

def avoid_obstacles(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  head_x = letty[:head_x]
  head_y = letty[:head_y]

  up = { x: head_x, y: head_y - 1 }
  down = { x: head_x, y: head_y + 1 }
  left = { x: head_x - 1, y: head_y }
  right = { x: head_x + 1, y: head_y }

  up_2 = { x: head_x, y: head_y - 2 }
  down_2 = { x: head_x, y: head_y + 2 }
  left_2 = { x: head_x - 2, y: head_y }
  right_2 = { x: head_x + 2, y: head_y }

  # This checks for letty, other snakes, and walls in each direction - if found, that direction is removed
  board[:snakes].each do |snake|
    if letty[:body].include?(up) || snake[:body].include?(up) || up[:y] == -1
      directions.delete(:up)
    end
    if letty[:body].include?(down) || snake[:body].include?(down) || down[:y] == board[:height]
      directions.delete(:down)
    end
    if letty[:body].include?(left) || snake[:body].include?(left) || left[:x] == -1
      directions.delete(:left)
    end
    if letty[:body].include?(right) || snake[:body].include?(right) || right[:x] == board[:width]
      directions.delete(:right)
    end
  end

  if directions.length > 1
    board[:snakes].each do |snake|
      if letty[:body].include?(up_2) || snake[:body].include?(up_2) || up_2[:y] == -1
        directions.delete(:up)
      end
      if letty[:body].include?(down_2) || snake[:body].include?(down_2) || down_2[:y] == board[:height]
        directions.delete(:down)
      end
      if letty[:body].include?(left_2) || snake[:body].include?(left_2) || left_2[:x] == -1
        directions.delete(:left)
      end
      if letty[:body].include?(right_2) || snake[:body].include?(right_2) || right_2[:x] == board[:width]
        directions.delete(:right)
      end
    end
  
    if (letty[:health] <= 60)
      seek_food(data, directions)
    end
  
    directions

  end

  directions

end

def seek_food(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  head_x = letty[:head_x]
  head_y = letty[:head_y]
  up = { x: head_x, y: head_y - 1 }
  down = { x: head_x, y: head_y + 1 }
  left = { x: head_x - 1, y: head_y }
  right = { x: head_x + 1, y: head_y }



  # CHECKS FOR FOOD ADJACENT TO HEAD
  if board[:food].include?(up)
    directions = [:up]
  end
  if board[:food].include?(down)
    directions = [:down]
  end
  if board[:food].include?(left)
    directions = [:left]
  end
  if board[:food].include?(right)
    directions = [:right]
  end
  
  # CHECKS FOR DIRECTION OF "MOST FOOD" ON THE BOARD
  food_x = []
  food_y = []
  x_left = []
  x_right = []
  y_above = []
  y_below = []

  board[:food].each do |food|
    food_x.push(food[:x])
    food_y.push(food[:y])
  end

  puts "board food: \n X: #{food_x}, \n Y: #{food_y}"
  # CHECKING X AXIS COMPARED TO HEAD
  food_x.each do |x_val|
    if x_val < head_x
      x_left.push(x_val)
    end
    if x_val > head_x
      x_right.push(x_val)
    end

    puts "board food: \n x_left: #{x_left} \n x_right: #{x_right}"
  end

  # CHECKING Y AXIS COMPARED TO HEAD
  food_y.each do |y_val|
    if y_val < head_y
      y_above.push(y_val)
    end
    if y_val > head_y
      y_below.push(y_val)
    end

    puts "board food: \n y_above: #{y_above} \n y_below: #{y_below}"

  end
  
  puts "CHECKING VARIABLES: \n y_above: #{y_above} \n y_below: #{y_below}"

  # MOVE COMMANDS BASED ON BOARD FOOD ^
  if directions.include?(:up) #&& (y_above >= y_below)
    puts "up = true"
    directions = [:up]
  end
  # if directions.include?(:down) && (y_below >= y_above)
  #   puts "down = true"
  #   directions = [:down]
  # end
  # if directions.include?(:left) && (x_left >= x_right)
  #   puts "left = true"
  #   directions = [:left]
  # end
  # if directions.include?(:right) && (x_right >= x_left)
  #   puts "right = true"
  #   directions = [:right]
  # end
  
  directions
end

def chase_tail(data, directions)
  letty = readable_letty_data(data)

  if letty[:head_x] < letty[:tail_x] and directions.include?(:left)
    directions.delete(:left)
    directions.push(:right)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_x] > letty[:tail_x] and directions.include?(:right)
    directions.delete(:right)
    directions.push(:left)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_y] < letty[:tail_y] and directions.include?(:up)
    directions.delete(:up)
    directions.push(:down)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_y] > letty[:tail_y] and directions.include?(:down)
    directions.delete(:down)
    directions.push(:up)
    directions = avoid_obstacles(data, directions)
  end
  directions
end
