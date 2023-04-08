extends Node2D

# Signals
# Score
signal update_score
signal set_max_score
# Counter
signal counter_changed
# Goals
signal check_goal
# Game Over
signal game_over
signal game_won
# Sound
signal play_sound

# Enum
enum {WAIT, MOVE, WON}


# Export Variables
export (int) var level
# Grid Variables
export (int) var y_offset

# Obstacle Variables
export (PoolVector2Array) var concrete_spaces
export (PoolVector2Array) var empty_spaces
export (PoolVector2Array) var ice_spaces
export (PoolVector2Array) var lock_spaces
export (PoolVector2Array) var slime_spaces

# Scoring Variables
export (int) var piece_value
export (int) var max_score

# Counter
export (int) var counter_value
export (bool) var is_move

# Sinker
export (PackedScene) var sinker_piece
export (bool) var is_sinker_in_scene
export (int) var max_sinkers

# Preset pieces
export (PoolVector3Array) var preset_pieces

# Public Variables
# Grid
var height = Global.height
var width = Global.width
var offset =  Global.offset
var x_start =  Global.x_start
var y_start =  Global.y_start
var no_piece_types: int 

var piece_prototype = preload("res://scenes/piece.tscn")
var all_pieces = []
var current_matches = []
var hint_matches = []
var hint_holder = []

# Input 
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

# Obstacle Variables
var damaged_slime = false

# Swap back variables
var piece_one = null
var piece_two = null
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)
var move_checked = false

# Scoring Variables
var streak = 1
var score = 0 setget ,get_score

# State Machine
var state

# Bomb variables
var color_bomb_used = false

# Particle effects
var particle_effect = preload("res://scenes/ParticleEffect.tscn")
var animated_effect = preload("res://scenes/animatedExplosion.tscn")

# Sinker
var current_sinkers = []


func _ready():
	pass


func _process(_delta):
	if state == MOVE:
		touch_input()


# Function used to initilize the grid
func init(Level: int, Concrete_Spaces: PoolVector2Array, 
Empty_Spaces: PoolVector2Array, Ice_Spaces: PoolVector2Array, Lock_Spaces: PoolVector2Array, Slime_Spaces: PoolVector2Array,
Max_Score: int, Counter_Value: int, Is_Move: bool, Piece_Value: int, Is_sinker_in_scene: bool, Max_sinkers: int, No_piece_types: int):
	level = Level
	concrete_spaces = Concrete_Spaces
	empty_spaces = Empty_Spaces
	ice_spaces = Ice_Spaces
	lock_spaces = Lock_Spaces
	slime_spaces = Slime_Spaces
	piece_value = Piece_Value
	max_score = Max_Score
	counter_value = Counter_Value
	is_move = Is_Move
	is_sinker_in_scene = Is_sinker_in_scene
	max_sinkers = Max_sinkers
	no_piece_types = No_piece_types
	
	state = MOVE
	randomize()
	all_pieces = make_2d_array()
	spawn_preset_pieces()
	if is_sinker_in_scene:
		spawn_sinker(max_sinkers)
	$ConcreteHolder.make(concrete_spaces)
	$LockHolder.make(lock_spaces)
	$IcyHolder.make(ice_spaces)
	$SlimeHolder.make(slime_spaces)
	spawn_pieces()
	emit_signal("counter_changed", counter_value)
	emit_signal("set_max_score", max_score)
	if !is_move:
		$Timer.start()
	$HintTimer.start()


func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		var mouse = get_global_mouse_position()
		mouse = transform_pixel_to_grid(mouse.x, mouse.y)
		if is_in_grid(mouse.x, mouse.y):
			first_touch = mouse
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		var mouse = get_global_mouse_position()
		mouse = transform_pixel_to_grid(mouse.x, mouse.y)
		if is_in_grid(mouse.x, mouse.y) and controlling:
			controlling = false
			touch_difference(first_touch, mouse)


func touch_difference(grid_1: Vector2, grid_2: Vector2):
	$HintTimer.start()
	var difference = grid_1-grid_2
	var temp_timer = get_tree().create_timer(0.5)
	var direction = Vector2(0, 0)
	if abs(difference.aspect()) == 1:
		return
	if abs(difference.aspect()) < 1:
		if difference.y > 0:
			direction = Vector2.UP
		elif difference.y < 0:
			direction = Vector2.DOWN
	else:
		if difference.x > 0:
			direction = Vector2.LEFT			
		elif difference.x < 0:
			direction = Vector2.RIGHT
			
	swap_pieces(grid_1.x, grid_1.y, direction)
	if !find_matches():
		yield(temp_timer, "timeout")
		swap_pieces(grid_1.x, grid_1.y, direction)
		state = MOVE

# spawns inital grid
func spawn_pieces():
	for column in width:
		for row in height:
			if all_pieces[column][row] != null:
				continue
			if is_fill_restricted_at(Vector2(column, row)):
				continue
			var list = Global.PieceType.keys()
			if no_piece_types != list.size():
				list = list.slice(0, no_piece_types)
			var rand = list.pop_at(floor(rand_range(0, list.size())))
			var piece = piece_prototype.instance()
			while is_match_at(column, row, rand) and list.size() > 1:
				rand = list.pop_at(floor(rand_range(0, list.size())))
			add_child(piece)
			piece.position = transform_grid_to_pixel(column, row)
			piece.init(rand)
			piece.set_row(row)
			piece.set_column(column)
			all_pieces[column][row] = piece
	if is_deadlock():
		shuffle_board()


func spawn_sinker(number):
	if !is_sinker_in_scene:
		return
	var allowed_places = []
	for i in width:
		if !is_fill_restricted_at(Vector2(i, height - 1)):
			allowed_places.append(i)
	for j in number:
		var rand = allowed_places.pop_at(floor(rand_range(0, allowed_places.size())))
		var current = piece_prototype.instance()
		add_child(current)
		current.is_sinker = true
		current.init("RED")
		current.position = transform_grid_to_pixel(rand, height -  1)
		current.set_row(height -  1)
		current.set_column(rand)
		all_pieces[rand][height - 1] = current
		current_sinkers.append(current)


# spawns pieces for debugging
func spawn_preset_pieces():
	if preset_pieces == null:
		return
	if preset_pieces.size() > 0:
		var list = Global.PieceType.keys()
		if no_piece_types != list.size():
			list = list.slice(0, no_piece_types)
		for i in preset_pieces.size():
			var current = preset_pieces[i]
			var piece =  piece_prototype.instance()
			piece.init(list[current.z])
			add_child(piece)
			piece.position = transform_grid_to_pixel(current.x, current.y)
			all_pieces[current.x][current.y] = piece


func find_matches(query = false, array = all_pieces, found_matches_array = current_matches):
	var found_match = false
	for column in width:
		for row in height:
			if array[column][row] == null:
				continue
			if array[column][row].matched == true:
				found_match = true
			var current_color = array[column][row].color
			if column > 0 and column < width - 1:
				if array[column - 1][row] != null and array[column + 1][row] != null:
					if array[column - 1][row].color == current_color and array[column + 1][row].color == current_color:
						if query:
							return true
						set_matched(array[column][row])
						set_matched(array[column - 1][row])
						set_matched(array[column + 1][row])
						
						add_to_array(Vector2(column, row), found_matches_array)
						add_to_array(Vector2(column - 1, row), found_matches_array)
						add_to_array(Vector2(column + 1, row), found_matches_array)
						found_match = true
			if row > 0 and row < height - 1:
				if array[column][row - 1] != null and array[column][row + 1] != null:
					if array[column][row - 1].color == current_color and array[column][row + 1].color == current_color:
						if query:
							return true
						set_matched(array[column][row])
						set_matched(array[column][row - 1])
						set_matched(array[column][row + 1])

						add_to_array(Vector2(column, row), found_matches_array)
						add_to_array(Vector2(column, row -  1), found_matches_array)
						add_to_array(Vector2(column, row + 1), found_matches_array)
						found_match = true
	if query:
		return false
		
	if found_match and array == all_pieces: 
		#get_bombed_pieces()
		$DestroyTimer.start()
	else:
		state = MOVE
	return found_match


func generate_hint():
	find_all_matches()
	var array = hint_holder
	if array == null:
		return
	var list = []
	for i in array.size():
		list.append(array[i][0])
	var max_value_idx = list.find(list.max())
	var hint = array[max_value_idx]
	var pos = hint[1]
	if all_pieces[pos.x][pos.y].color == hint[3]:
		all_pieces[pos.x][pos.y].wiggle(-hint[2])
	else:
		pos = pos + hint[2]
		all_pieces[pos.x][pos.y].wiggle(hint[2])
	hint_holder = []


func find_all_matches():
	var copy = all_pieces.duplicate(true)
	for column in width:
		for row in height:
			hint_matches = []
			if copy[column][row] == null:
				continue

			var check = check_for_matches(Vector2(column, row), Vector2.UP, copy)
			if check.size() != 0:
				hint_holder.append([check[0], Vector2(column, row), Vector2.UP, check[1][0]])
			hint_matches = []

			check = check_for_matches(Vector2(column, row), Vector2.LEFT, copy)
			if check.size() != 0:
				hint_holder.append([check[0], Vector2(column, row), Vector2.LEFT, check[1][0]])


func check_for_matches(place, direction, array):
	var list = []
	var out = []
	for column in width:
		for row in height:
			if array[column][row] == null:
				continue
			array[column][row].matched = false
	
	if switch_pieces(place, direction, array):
		if !find_matches(false, array, hint_matches):
			switch_pieces(place, direction, array)
			return out
		out.append(hint_matches.size())
		for i in hint_matches.size():
			var m = hint_matches[i]
			array[m.x][m.y].matched = false
			list.append(array[m.x][m.y].color)
		var color_count = list.count(list[0])
		out.append([list[0], color_count])
		if color_count == hint_matches.size():
			switch_pieces(place, direction, array)
			return out
		var count = list.size() - color_count
		for i in range(list.size() -1,  -1, -1):
			if list[0] == list[i]:
				list.remove(i)
		out.append([list[0], count])
		switch_pieces(place, direction, array)
	return out


func switch_and_check(place, direction, array):
	switch_pieces(place, direction, array)
	if find_matches(true, array):
		switch_pieces(place, direction, array)
		return true
	switch_pieces(place, direction, array)
	return false


func switch_pieces(place, direction, array):
	if !is_in_grid(place.x, place.y) or !is_in_grid(place.x + direction.x, place.y + direction.y):
		return false
	if is_fill_restricted_at(place) or is_fill_restricted_at(place + direction):
		return false
	if is_move_restricted_at(place) or is_move_restricted_at(place + direction):
		return false
	var temp = array[place.x + direction.x][place.y + direction.y]
	array[place.x + direction.x][place.y + direction.y] = array[place.x][place.y]
	array[place.x][place.y] = temp
	return true


func find_bombs():
	if color_bomb_used:
		return
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		var current_color = all_pieces[current_column][current_row].color
		var matches = find_col_row_matches(i) 
		var col_matched = matches[0]
		var row_matched = matches[1]
		if col_matched >= 5 or row_matched >= 5:
			make_bomb(current_color)
		elif col_matched == 3 and row_matched == 3:
			make_bomb(current_color)
		elif col_matched == 4:
			clear_column(current_column)
		elif row_matched == 4:
			clear_row(current_row)


func find_col_row_matches(i, array = current_matches):
	var current_column = array[i].x
	var current_row = array[i].y
	var current_color = all_pieces[current_column][current_row].color
	var col_matched = 0
	var row_matched = 0
	for j in array.size():
		var this_column = array[j].x
		var this_row = array[j].y
		var this_color = all_pieces[this_column][this_row].color
		if this_column == current_column and current_color == this_color:
			col_matched +=1
		if this_row == current_row and current_color == this_color:
			row_matched +=1
	return [col_matched, row_matched]


func make_bomb(color):
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		if all_pieces[current_column][current_row] == piece_one and piece_one.color == color:
			damage_special(current_column, current_row)
			emit_signal("check_goal", piece_one.color)
			piece_one.matched = false
			piece_one.make_color_bomb()
		if all_pieces[current_column][current_row] == piece_two and piece_two.color == color:
			damage_special(current_column, current_row)
			emit_signal("check_goal", piece_two.color)
			piece_two.matched = false
			piece_two.make_color_bomb()


#func call_bomb(bomb_type, piece):
#	match bomb_type:
#		"color bomb":
#			piece.make_color_bomb()
#		"adjacent bomb":
#			piece.make_adjacent_bomb()
#		"column bomb":
#			piece.make_column_bomb()
#		"row bomb":
#			piece.make_row_bomb()


func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece == null or other_piece == null:
		return
	if is_move_restricted_at(Vector2(column, row)) or is_move_restricted_at(Vector2(column, row) + direction):
		return
	store_info(first_piece, other_piece, Vector2(column, row), direction)
	state = WAIT
	all_pieces[column][row] = other_piece
	all_pieces[column + direction.x][row + direction.y] = first_piece
	first_piece.move(transform_grid_to_pixel(column + direction.x, row + direction.y))
	first_piece.set_row(row + direction.y)
	first_piece.set_column (column + direction.x)
	other_piece.move(transform_grid_to_pixel(column, row))
	other_piece.set_row(row)
	other_piece.set_column (column)
	
	if first_piece.is_color_bomb and other_piece.is_color_bomb:
		clear_board()
		return
	if first_piece.is_color_bomb:
		if is_sinker(column, row):
			swap_back()
			return
		clear_color(other_piece.color)
		set_matched(first_piece)
		add_to_array(Vector2(column, row), current_matches) 
		color_bomb_used = true
	if other_piece.is_color_bomb:
		if is_sinker(column + direction.x, row + direction.y):
			swap_back()
			return
		clear_color(first_piece.color)
		set_matched(other_piece)
		add_to_array(Vector2(column + direction.x, row + direction.y), current_matches)
		color_bomb_used = true
	if !move_checked:
		find_matches()


func swap_back():
	if piece_one != null and piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = MOVE
	move_checked = false


func destroy_matched():
	find_bombs()
	var was_matched = false
	for column in width:
		for row in height:
			if all_pieces[column][row] == null:
				continue
			if !all_pieces[column][row].matched:
				continue
			emit_signal("check_goal", all_pieces[column][row].color)
			damage_special(column, row)
			was_matched = true
			all_pieces[column][row].queue_free()
			all_pieces[column][row] = null
#			make_effect(particle_effect, column, row)
			make_effect(animated_effect, column, row)
			score += piece_value * streak
			emit_signal("play_sound")
			emit_signal("update_score", score)
	move_checked = true
	if was_matched:
		$CollapseTimer.start()
	else: 
		swap_back()
	current_matches.clear()


func make_effect(effect, column, row):
	var curent = effect.instance()
	curent.position = transform_grid_to_pixel(column, row)
	add_child(curent)


func damage_special(column, row):
	$IcyHolder.damage(Vector2(column, row))
	$LockHolder.damage(Vector2(column, row))
	check_special(column, row)


func check_special(column, row):
	if column < width - 1:
		$SlimeHolder.damage(Vector2(column + 1, row))
		$ConcreteHolder.damage(Vector2(column + 1, row))
	if column > 0 and column < width:
		$SlimeHolder.damage(Vector2(column - 1, row))
		$ConcreteHolder.damage(Vector2(column - 1, row))
	if row < height - 1:
		$SlimeHolder.damage(Vector2(column, row + 1))
		$ConcreteHolder.damage(Vector2(column, row + 1))
	if row > 0 and row < height:
		$SlimeHolder.damage(Vector2(column, row - 1))
		$ConcreteHolder.damage(Vector2(column, row - 1))


func collapse_columns():
	if state == WON:
		return
	for column in width:
		for row in height:
			if all_pieces[column][row] != null or is_fill_restricted_at(Vector2(column, row)):
				continue
			for k in range(row + 1, height):
				var current = all_pieces[column][k]
				if current == null:
					continue
				if is_move_restricted_at(Vector2(column, k)):
					continue
				all_pieces[column][k].move(transform_grid_to_pixel(column, row))
				all_pieces[column][k].set_row(row)
				all_pieces[column][k].set_column(column)
				all_pieces[column][row] = all_pieces[column][k]
				all_pieces[column][k] = null
				break
	destroy_sinkers()
	$RefillTimer.start()


func refill_columns():
	if current_sinkers.size() < max_sinkers:
		spawn_sinker(max_sinkers - current_sinkers.size())
	streak += 1
	for column in width:
		for row in height:
			if all_pieces[column][row] != null or is_fill_restricted_at(Vector2(column, row)):
				continue
			var list = Global.PieceType.keys()
			if no_piece_types != list.size():
				list = list.slice(0, no_piece_types)
			var rand = list.pop_at(floor(rand_range(0, list.size())))
			var piece = piece_prototype.instance()
			while is_match_at(column, row, rand) and list.size() > 1:
				rand = list.pop_at(floor(rand_range(0, list.size())))
			add_child(piece)
			piece.position = transform_grid_to_pixel(column, row - y_offset)
			piece.move(transform_grid_to_pixel(column, row))
			piece.init(rand)
			piece.set_row(row)
			piece.set_column(column)
			all_pieces[column][row] = piece
	after_refill()


func after_refill():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null:
				continue
			if is_match_at(column, row, all_pieces[column][row].color) or all_pieces[column][row].matched:
				find_matches()
				$DestroyTimer.start()
				return
	state = MOVE
	streak = 1
	move_checked = false
	if !damaged_slime:
		generate_slime()
	damaged_slime = false
	color_bomb_used = false
	if is_deadlock():
		shuffle_board()
	if is_move:
		counter_value -=1
		emit_signal("counter_changed")
		if counter_value == 0:
			game_over()
	$HintTimer.start()


func destroy_sinkers():
	for i in range(current_sinkers.size() - 1,  -1, -1):
		if current_sinkers[i] != null:
			var row = current_sinkers[i].get_row()
			var column = current_sinkers[i].get_column()
			if row == 0:
				current_sinkers.remove(i)
				all_pieces[column][row].matched = true


# returns a random non-slime neighbor
func find_normal_tile(column, row):
	var list = []
	list.append(Vector2(column + 1, row))
	list.append(Vector2(column  - 1, row))
	list.append(Vector2(column, row  + 1))
	list.append(Vector2(column, row  - 1))
	
	for i in range(list.size() -1,  -1, -1):
		if !is_in_grid(list[i].x, list[i].y) or all_pieces[list[i].x][list[i].y] == null or is_sinker(list[i].x, list[i].y):
			list.remove(i)
	
	if list.size() > 0:
		return list.pop_at(floor(rand_range(0, list.size())))
	else:
		return null


func generate_slime():
	if slime_spaces.size() > 0:
		var list  = []
		for i in slime_spaces.size():
			list.append(slime_spaces[i])
		var slime_made = false
		while list.size() > 0 and !slime_made:
			var rand = list.pop_at(floor(rand_range(0, list.size())))
			var neighbor = find_normal_tile(rand.x, rand.y)
			if neighbor == null:
				continue
			all_pieces[neighbor.x][neighbor.y].queue_free()
			all_pieces[neighbor.x][neighbor.y] = null
			slime_spaces.append(Vector2(neighbor.x, neighbor.y))
			$SlimeHolder.make([Vector2(neighbor.x, neighbor.y)])
			slime_made = true
	damaged_slime = false


# Match pieces in columns, rows and the whole board
func clear_column(column):
	for i in height:
		var current = all_pieces[column][i] 
		if current == null or is_sinker(column, i):
			continue
		if  current.matched:
			continue
		if current.is_color_bomb:
			all_pieces[column][i].matched = false
			continue
		all_pieces[column][i].matched = true


func clear_row(row):
	for i in width:
		var current = all_pieces[i][row] 
		if current == null or is_sinker(i, row):
			continue
		if current.matched:
			continue
		if current.is_color_bomb:
			all_pieces[i][row].matched = false
			continue
		all_pieces[i][row].matched = true


func clear_color(color):
	for column in width:
		for row in height:
			if is_sinker(column, row):
				continue
			if all_pieces[column][row] == null or all_pieces[column][row].color != color:
				continue
			set_matched(all_pieces[column][row])
			add_to_array(Vector2(column, row), current_matches)


func clear_board():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null or is_sinker(column, row):
				continue
			set_matched(all_pieces[column][row])


func shuffle_board():
	var list = []
	for column in width:
		for row in height:
			if all_pieces[column][row] == null:
				continue
			list.append(all_pieces[column][row])
			all_pieces[column][row] = null
	for column in width:
		for row in height:
			if is_fill_restricted_at(Vector2(column, row)):
				continue
			var index = floor(rand_range(0, list.size()))
			var rand = list[index]
			while is_match_at(column, row, rand.color):
				index = floor(rand_range(0, list.size()))
				rand = list[index]
			rand.move(transform_grid_to_pixel(column, row))
			rand.set_row(row)
			rand.set_column(column)
			all_pieces[column][row] = rand
			list.remove(index)
	if is_deadlock():
		shuffle_board()


# helper functions
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func add_to_array(value, traget_array):
	if !traget_array.has(value):
		traget_array.append(value)


func copy_array(array):
	var copy = array.duplicate(true)
	return copy


func store_info(first_piece, other_piece, place, direction):
	piece_one =  first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction

	
# Coordinate transformations
func transform_grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func transform_pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)


# Check functions
func is_in_grid(column, row):
	if column < 0 or column >= width:
		return false
	if row < 0 or row >= height:
		return false
	return true


func is_match_at(column, row, color):
	if column > 1:
		if all_pieces[column - 1][row] != null and all_pieces[column - 2][row] != null:
			if all_pieces[column - 1][row].color == color and all_pieces[column - 2][row].color == color:
				return true
	if row > 1:
		if all_pieces[column][row - 1] != null and all_pieces[column][row - 2] != null:
			if all_pieces[column][row - 1].color == color and all_pieces[column][row - 2].color == color:
				return true
	return false


func is_sinker(column, row):
	for i in current_sinkers.size():
		if current_sinkers[i].position == transform_grid_to_pixel(column, row):
			return true
	return false


func is_deadlock():
	var copy = copy_array(all_pieces)
	for column in width:
		for row in height:
			if switch_and_check(Vector2(column, row), Vector2(1,0), copy):
				return false
			if switch_and_check(Vector2(column, row), Vector2(0,1), copy):
				return false
	return true


func is_fill_restricted_at(place):
	if empty_spaces.has(place):
		return true
	if concrete_spaces.has(place):
		return true
	if slime_spaces.has(place):
		return true
	return false


func is_move_restricted_at(place):
	if lock_spaces.has(place):
		return true
	return false

func set_matched(item):
	item.matched = true


func get_score():
	return score


func game_over():
	emit_signal("game_over")
	state = WAIT
	GameDataManager.save_data()


# Signals
func _on_destroy_timer_timeout():
	destroy_matched()


func _on_collapse_timer_timeout():
	collapse_columns()


func _on_refill_timer_timeout():
	refill_columns()


func _on_Timer_timeout():
	counter_value -= 1
	emit_signal("counter_changed")
	if counter_value != 0:
		return
	$Timer.stop()
	if state != WON:
		game_over()


# Obstacle signals
func _on_IcyHolder_destroyed(place, _value):
	for i in range(ice_spaces.size() -1,  -1, -1):
		if ice_spaces[i] == place:
			ice_spaces.remove(i)


func _on_SlimeHolder_destroyed(place, _value):
	damaged_slime = true
	for i in range(slime_spaces.size() -1,  -1, -1):
		if slime_spaces[i] == place:
			slime_spaces.remove(i)


func _on_ConcreteHolder_destroyed(place, _value):
	for i in range(concrete_spaces.size() -1,  -1, -1):
		if concrete_spaces[i] == place:
			concrete_spaces.remove(i)


func _on_LockHolder_destroyed(place, _value):
	for i in range(lock_spaces.size() -1,  -1, -1):
		if lock_spaces[i] == place:
			lock_spaces.remove(i)


func _on_HintTimer_timeout():
	generate_hint()


func _on_top_ui_game_won():
	state = WON
	if GameDataManager.level_info[level]["high_score"] < score:
		GameDataManager.level_info[level]["high_score"] = score
		GameDataManager.level_info[level]["date"] = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)
	if GameDataManager.level_info.has(level + 1):
		GameDataManager.level_info[level + 1]["unlocked"] = true
	GameDataManager.save_data()
	emit_signal("game_won", score)
	pass # Replace with function body.
