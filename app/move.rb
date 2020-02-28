# TODO: Implement your logic here!
# View docs at https://docs.battlesnake.com/snake-api for example payloads.

# This is used to output all the data for our snake, Letty.
# Add needed letty info here, access it by calling method.
def readable_letty_data(data)
  letty = data[:you]
  letty_body = letty[:body]
  letty_tail = letty[:body].last
  letty_data = {
    snek: letty,
    health: letty[:health],
    body: letty_body,
    head: letty_body.first,
    head_x: letty_body.first[:x],
    head_y: letty_body.first[:y],
    tail: letty_tail,
    tail_x: letty_tail[:x],
    tail_y: letty_tail[:y],
    phantom_tail_x: letty_tail[:x] - 1,
    phantom_tail_x: letty_tail[:y] - 1
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
  # puts letty[:tail]
  # puts letty[:body].length
  # puts letty[:phantom_tail]
  # puts letty[:phantom_tail_x]
  # puts letty[:phantom_tail_y]
  directions = [:up, :down, :left, :right]
  safe_directions = avoid_obstacles(data, directions)
  move = safe_directions.sample


  if (letty[:health] >= 90)
    move = chase_tail(data, safe_directions).last
    puts "I'm chasing my tail \n #{safe_directions}"
    { move: move }
  elsif (letty[:health] < 90 && letty[:health] > 60)
    move = eat_adjacent_food(data, safe_directions).last
    puts "I'm eating adjacent food \n #{safe_directions}"
    { move: move }
  elsif (letty[:health] <= 60)
    seek_closest_food(data, safe_directions).last
    puts "I'm seeking out closest food \n #{safe_directions}"
    { move: move }
  else
    {move: move}
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

  # # UPPER LEFT
  # if (head_x <= 1 && head_y <= 1)
  #   directions = [:down, :right]
  
  # # LOWER LEFT
  # elsif (head_x <= 1 && head_y <= (board[:height] - 1))
  #   directions = [:up, :right] 

  # # LOWER RIGHT
  # elsif (head_x <= (board[:width] - 1) && head_y <= (board[:height] - 1))
  #   directions = [:up, :left]

  # # UPPER RIGHT
  # elsif (head_x <= (board[:width] - 1) && head_y <= 1)
  #   directions = [:down, :left]
  
  # puts "AFTER CORNER DIRECTIONS: #{directions}"
  # else
    # directions = corner_check(data, directions)
    # directions = head_on_collision(data, directions)

    # This checks for letty's body, other snakes, and walls in each direction
    # If obstacle is found, that direction is removed
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
    end
  # end
  directions
end

# def corner_check(data, directions)
#   letty = readable_letty_data(data)
#   board = readable_board_data(data)

#   head_x = letty[:head_x]
#   head_y = letty[:head_y]
  
#   if head_x <= 1 && head_y <= 1
#     directions.delete(:left)
#     directions.delete(:up)
#   end
#   puts "#{directions}"
# end

def seek_closest_food(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  closest_food_result = determine_closest_food(data, board[:food], directions)

  if (letty[:head_y] == closest_food_result[:y] and directions.include?(:right) and letty[:head_x] < closest_food_result[:x])
    directions = [:right]
    return directions
  end
  if (letty[:head_y] == closest_food_result[:y] and directions.include?(:left) and letty[:head_x] > closest_food_result[:x])
    directions = [:left]
    return directions
  end
  if (letty[:head_x] == closest_food_result[:x] and directions.include?(:down) and letty[:head_y] < closest_food_result[:y])
    directions = [:down]
    return directions
  end
  if (letty[:head_x] == closest_food_result[:x] and directions.include?(:up) and letty[:head_y] > closest_food_result[:y])
    directions = [:up]
    return directions
  end

  if directions.include?(:left) and letty[:head_x] < closest_food_result[:x]
    directions.delete(:left)
  end
  if directions.include?(:right) and letty[:head_x] > closest_food_result[:x]
    directions.delete(:right)
  end
  if directions.include?(:up) and letty[:head_y] < closest_food_result[:y]
    directions.delete(:up)
  end
  if directions.include?(:down) and letty[:head_y] > closest_food_result[:y]
    directions.delete(:down)
  end
  return directions
end

def determine_closest_food(data, food_list, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  closest_food = nil
  shortest_distance = 10000

  i = 0
  for item in food_list
    food_x = food_list[i][:x]
    food_y = food_list[i][:y]
    distance_x = letty[:head_x] - food_x
    distance_y = letty[:head_y] - food_y

    total_distance = Math.sqrt((distance_x ** 2) + (distance_y ** 2))

    if closest_food == nil
      shortest_distance = total_distance
      closest_food = item
    end

    if total_distance < shortest_distance
      shortest_distance = total_distance
      closest_food = item
    end
    i = i + 1
  end

  return closest_food
end

def eat_adjacent_food(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  head_x = letty[:head_x]
  head_y = letty[:head_y]

  up = { x: head_x, y: head_y - 1 }
  down = { x: head_x, y: head_y + 1 }
  left = { x: head_x - 1, y: head_y }
  right = { x: head_x + 1, y: head_y }

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

  directions
end

def chase_tail(data, directions)
  letty = readable_letty_data(data)

  if letty[:head_x] < letty[:tail_x] && directions.include?(:left)
    directions.delete(:left)
    directions.push(:right)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_x] > letty[:tail_x] && directions.include?(:right)
    directions.delete(:right)
    directions.push(:left)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_y] < letty[:tail_y] && directions.include?(:up)
    directions.delete(:up)
    directions.push(:down)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_y] > letty[:tail_y] && directions.include?(:down)
    directions.delete(:down)
    directions.push(:up)
    directions = avoid_obstacles(data, directions)
  end
  directions
end

def head_on_collision(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)
  letty_size = letty[:body].length

  head_x = letty[:head_x]
  head_y = letty[:head_y]

  our_possible_moves = [
    { x: head_x, y: head_y - 1 },
    { x: head_x, y: head_y + 1 },
    { x: head_x - 1, y: head_y },
    { x: head_x + 1, y: head_y }
  ]

  for i in 1..board[:snakes].length - 1
    snake = board[:snakes][i]
    if snake[:body][0] != letty[:head]
      if snake[:body].length >= letty_size
        their_possible_moves = check_snake_head(snake[:body][0])
        directions = remove_bad_directions(their_possible_moves, our_possible_moves, directions)
      end
    end
  end
  directions
end

def check_snake_head(head)
  possible_moves = [
    { x: head[:x], y: head[:y] - 1 },
    { x: head[:x], y: head[:y] + 1 },
    { x: head[:x] - 1, y: head[:y] },
    { x: head[:x] + 1, y: head[:y] }
  ]
  possible_moves
end

def remove_bad_directions(their_possible_moves, our_possible_moves, directions)
  direction_keys = {0 => :up, 1 => :down, 2 => :left, 3 => :right}
  for i in 0..3 do
    our_move = our_possible_moves[i]
    if their_possible_moves.include?(our_move)
      directions.delete(direction_keys[i])
    end
  end
  directions
end
