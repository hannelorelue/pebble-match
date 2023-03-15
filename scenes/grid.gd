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

# Enum
enum {WAIT, MOVE, WON}


# Export Variables
# Grid Variables

export (int) var x_start
export (int) var y_start
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
export (int) var current_counter_value
export (bool) var is_move

# Sinker
export (PackedScene) var sinker_piece
export (bool) var sinker_in_scene
export (int) var max_sinkers

# Preset pieces
export (PoolVector3Array) var preset_pieces

# Public Variables
# Grid
var height = Global.height
var width = Global.width
var offset =  Global.offset

var piece_pool = [
	preload("red.tscn"),
	preload("pink.tscn"),
	preload("orange.tscn"),
	preload("green.tscn"),
	preload("blue.tscn"),
	preload("black.tscn"),
]
var all_pieces = []
var current_matches = []

# Input 
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

# Obstacle Variables
var damaged_slime = false

# Swap back variables
var 	piece_one = null
var piece_two = null
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)
var move_checked = false

# Scoring Variables
var streak = 1

# State Machine
var state

# Bomb variables
var color_bomb_used = false

# Particle effects
var particle_effect = preload("res://scenes/ParticleEffect.tscn")
var animated_effect = preload("res://scenes/animatedExplosion.tscn")

# Sinker
var current_sinkers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	state = MOVE
	randomize()
	all_pieces = make_2d_array()
	spawn_preset_pieces()
	if sinker_in_scene:
		spawn_sinker(max_sinkers)
	$concrete_holder.make(concrete_spaces)
	$LockHolder.make(lock_spaces)
	$IcyHolder.make(ice_spaces)
	$slime_holder.make(slime_spaces)
	spawn_pieces()
	emit_signal("counter_changed", current_counter_value)
	emit_signal("set_max_score", max_score)
	if !is_move:
		$Timer.start()


func _process(_delta):
	if state == MOVE:
		touch_input()


# spawm inital grid
func spawn_pieces():
	for column in width:
		for row in height:
			if all_pieces[column][row] != null:
				continue
			if is_fill_restricted_at(Vector2(column, row)):
				continue
			var list = range(piece_pool.size())
			var rand = list.pop_at(floor(rand_range(0, list.size())))
			var piece = piece_pool[rand].instance()
			while is_match_at(column, row, piece.color) and list.size() > 1:
				rand = list.pop_at(floor(rand_range(0, list.size())))
				piece = piece_pool[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(column, row)
			all_pieces[column][row] = piece
	if is_deadlock():
		shuffle_board()


func spawn_sinker(number):
	if  !sinker_in_scene:
		return
	var allowed_places = []
	for i in width:
		if !is_fill_restricted_at(Vector2(i, height - 1)):
			allowed_places.append(i)
	for j in number:
		var rand = allowed_places.pop_at(floor(rand_range(0, allowed_places.size())))
		var current = sinker_piece.instance()
		add_child(current)
		current.position =  grid_to_pixel(rand, height -  1)
		all_pieces[rand][height - 1] = current
		current_sinkers.append(current)


func spawn_preset_pieces():
	if preset_pieces == null:
		return
	if preset_pieces.size() > 0:
		for i in preset_pieces.size():
			var current = preset_pieces[i]
			var piece =  piece_pool[current.z].instance()
			add_child(piece)
			piece.position = grid_to_pixel(current.x, current.y)
			all_pieces[current.x][current.y] = piece



func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		var mouse = get_global_mouse_position()
		mouse = pixel_to_grid(mouse.x, mouse.y)
		if is_in_grid(mouse.x, mouse.y):
			first_touch = mouse
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		var mouse = get_global_mouse_position()
		mouse = pixel_to_grid(mouse.x, mouse.y)
		if is_in_grid(mouse.x, mouse.y) and controlling:
			controlling = false
			touch_difference(first_touch, mouse)


func touch_difference(grid_1, grid_2):
	var difference = grid_1-grid_2
	var temp_timer = get_tree().create_timer(0.5)
	if abs(difference.x) < abs(difference.y):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))
				state = MOVE

		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
				state = MOVE

	elif abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
				state = MOVE
			
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
				state = MOVE
	else:
		pass


func find_matches(query = false, array = all_pieces):
	var found_match = false
	for column in width:
		for row in height:
			if array[column][row] == null:
				continue
			if array[column][row].matched == true:
				found_match = true
			var current_color = array[column][row].color
			if column > 0 and column < width - 1:
				if array[column - 1][row] == null or array[column + 1][row] == null:
					continue
				if array[column - 1][row].color == current_color and array[column + 1][row].color == current_color:
					if query:
						return true
					matched_and_dim(array[column][row])
					matched_and_dim(array[column - 1][row])
					matched_and_dim(array[column + 1][row])
					
					add_to_array(Vector2(column, row))
					add_to_array(Vector2(column - 1, row))
					add_to_array(Vector2(column + 1, row))
					found_match = true
			
			if row > 0 and row < height - 1:
				if array[column][row - 1] == null or array[column][row + 1] == null:
					continue
				if array[column][row - 1].color == current_color and array[column][row + 1].color == current_color:
					if query:
						return true
					matched_and_dim(array[column][row])
					matched_and_dim(array[column][row - 1])
					matched_and_dim(array[column][row + 1])
					
					add_to_array(Vector2(column, row))
					add_to_array(Vector2(column, row -  1))
					add_to_array(Vector2(column, row + 1))
					found_match = true
	if query:
		return false
	if found_match: 
		get_bombed_pieces()
		get_parent().get_node("destroy_timer").start()
	else:
		state = MOVE
	return found_match


func find_bombs():
	if color_bomb_used:
		return
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		var current_color = all_pieces[current_column][current_row].color
		var col_matched = 0
		var row_matched = 0
		for j in current_matches.size():
			var this_column = current_matches[j].x
			var this_row = current_matches[j].y
			var this_color = all_pieces[this_column][this_row].color
			if this_column == current_column and current_color == this_color:
				col_matched +=1
			if this_row == current_row and current_color == this_color:
				row_matched +=1
		if col_matched >= 5 or row_matched >= 5:
			make_bomb("color bomb", current_color)
		elif col_matched == 3 and row_matched == 3:
			make_bomb("adjacent bomb", current_color)
		elif col_matched == 4:
			make_bomb("row bomb", current_color)
		elif row_matched == 4:
			make_bomb("column bomb", current_color)


func make_bomb(bomb_type, color):
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		if all_pieces[current_column][current_row] == piece_one and piece_one.color == color:
			damage_special(current_column, current_row)
			emit_signal("check_goal", piece_one.color)
			piece_one.matched = false
			call_bomb(bomb_type, piece_one)
		if all_pieces[current_column][current_row] == piece_two and piece_two.color == color:
			damage_special(current_column, current_row)
			emit_signal("check_goal", piece_two.color)
			piece_two.matched = false
			call_bomb(bomb_type, piece_two)


func call_bomb(bomb_type, piece):
	if bomb_type == "color bomb":
		piece.make_color_bomb()
	elif bomb_type == "adjacent bomb":
		piece.make_adjacent_bomb()
	elif bomb_type == "column bomb":
		piece.make_column_bomb()
	elif bomb_type == "row bomb":
		piece.make_row_bomb()


func get_bombed_pieces():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null or !all_pieces[column][row].matched:
				continue
			if all_pieces[column][row].is_column_bomb:
				match_pieces_in_column(column)
			elif all_pieces[column][row].is_row_bomb:
				match_pieces_in_row(row)
			elif all_pieces[column][row].is_adjacent_bomb:
				match_adjacent_pieces(column, row)


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
	first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
	other_piece.move(grid_to_pixel(column, row))
	if first_piece.is_color_bomb and other_piece.is_color_bomb:
		clear_board()
		return
	if first_piece.is_color_bomb:
		if is_sinker(column, row):
			swap_back()
			return
		match_color(other_piece.color)
		matched_and_dim(first_piece)
		add_to_array(Vector2(column, row)) 
		color_bomb_used = true
	if other_piece.is_color_bomb:
		if is_sinker(column + direction.x, row + direction.y):
			swap_back()
			return
		match_color(first_piece.color)
		matched_and_dim(other_piece)
		add_to_array(Vector2(column + direction.x, row + direction.y))
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
			make_effect(particle_effect, column, row)
			make_effect(animated_effect, column, row)
			emit_signal("update_score", piece_value * streak)
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else: 
		swap_back()
	current_matches.clear()


func make_effect(effect, column, row):
	var curent = effect.instance()
	curent.position = grid_to_pixel(column, row)
	add_child(curent)


func damage_special(column, row):
	$IcyHolder.damage(Vector2(column, row))
	$LockHolder.damage(Vector2(column, row))
	check_special(column, row)


func check_special(column, row):
	if column < width - 1:
		$slime_holder.damage(Vector2(column + 1, row))
		$concrete_holder.damage(Vector2(column + 1, row))
	if column > 0 and column < width:
		$slime_holder.damage(Vector2(column - 1, row))
		$concrete_holder.damage(Vector2(column - 1, row))
	if row < height - 1:
		$slime_holder.damage(Vector2(column, row + 1))
		$concrete_holder.damage(Vector2(column, row + 1))
	if row > 0 and row < height:
		$slime_holder.damage(Vector2(column, row - 1))
		$concrete_holder.damage(Vector2(column, row - 1))


func collapse_columns():
	if state == WON:
		return
	for column in width:
		for row in height:
			if all_pieces[column][row] != null or is_fill_restricted_at(Vector2(column, row)):
				continue
			for k in range(row + 1, height):
				if all_pieces[column][k] == null:
					continue
				all_pieces[column][k].move(grid_to_pixel(column, row))
				all_pieces[column][row] = all_pieces[column][k]
				all_pieces[column][k] = null
				break
	destroy_sinkers()
	get_parent().get_node("refill_timer").start()


func refill_columns():
	if current_sinkers.size() < max_sinkers:
		spawn_sinker(max_sinkers - current_sinkers.size())
	streak += 1
	for column in width:
		for row in height:
			if all_pieces[column][row] != null or is_fill_restricted_at(Vector2(column, row)):
				continue
			var list = range(piece_pool.size())
			
			var rand = list.pop_at(floor(rand_range(0, list.size())))
			var piece = piece_pool[rand].instance()
			while is_match_at(column, row, piece.color) and list.size() > 1:
				rand = list.pop_at(floor(rand_range(0, list.size())))
				piece = piece_pool[rand].instance()
				
			add_child(piece)
			piece.position = grid_to_pixel(column, row - y_offset)
			piece.move(grid_to_pixel(column, row))
			all_pieces[column][row] = piece
	after_refill()


func after_refill():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null:
				continue
			if is_match_at(column, row, all_pieces[column][row].color) or all_pieces[column][row].matched:
				find_matches()
				get_parent().get_node("destroy_timer").start()
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
		current_counter_value -=1
		emit_signal("counter_changed")
		if current_counter_value == 0:
			game_over()


func destroy_sinkers():
	for i in range(current_sinkers.size() - 1,  -1, -1):
		if current_sinkers[i] != null:
			var pos = pixel_to_grid(current_sinkers[i].position.x, current_sinkers[i].position.y)
			if pos.y == 0:
				current_sinkers.remove(i)
				all_pieces[pos.x][pos.y].matched = true


# returns a random non-slime neighbor
func find_normal_tile(column, row):
	var list = []
	list.append(Vector2(column + 1, row))
	list.append(Vector2(column  - 1, row))
	list.append(Vector2(column, row  + 1))
	list.append(Vector2(column, row  - 1))
	
	for i in range( list.size() -1,  -1, -1):
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
			$slime_holder.make([Vector2(neighbor.x, neighbor.y)])
			slime_made = true
	damaged_slime = false


# Match pieces in columns and rows, adjacent to a piece and the whole board
func match_pieces_in_column(column):
	for i in height:
		var current = all_pieces[column][i] 
		if current == null or is_sinker(column, i):
			continue
		if  current.matched:
			continue
		if current.is_row_bomb:
			all_pieces[column][i].matched = true
			match_pieces_in_row(i)
		if current.is_adjacent_bomb:
			all_pieces[column][i].matched = true
			match_adjacent_pieces(column, i)
		if current.is_color_bomb:
			all_pieces[column][i].matched = true
			match_color(all_pieces[column][i].color)
		all_pieces[column][i].matched = true


func match_pieces_in_row(row):
	for i in width:
		var current = all_pieces[i][row] 
		if current == null or is_sinker(i, row):
			continue
		if current.matched:
			continue
		if current.is_column_bomb:
			all_pieces[i][row].matched = true
			match_pieces_in_column(i)
		if current.is_adjacent_bomb:
			all_pieces[i][row].matched = true
			match_adjacent_pieces(i, row)
		if current.is_color_bomb:
			all_pieces[i][row].matched = true
			match_color(all_pieces[i][row].color)
		all_pieces[i][row].matched = true


func match_adjacent_pieces(column, row):
	for i in range(-1, 2):
		for j in range(-1, 2):
			var current = all_pieces[column + i][row + j] 
			if is_sinker(column + i, row + j):
				continue
			if !is_in_grid(column + i, row + j) or current  == null:
				continue
			if all_pieces[column + i][row + j].matched:
				continue
			if current .is_column_bomb:
				all_pieces[column + i][row + j].matched = true
				match_pieces_in_column(column + i)
			if current .is_row_bomb:
				all_pieces[column + i][row + j].matched = true
				match_pieces_in_row(row + j)
			if current .is_color_bomb:
				all_pieces[column + i][row + j].matched = true
				match_pieces_in_row(row + j)
			all_pieces[column + i][row + j].matched = true


func match_color(color):
	for column in width:
		for row in height:
			if is_sinker(column, row):
				continue
			if all_pieces[column][row] == null or all_pieces[column][row].color != color:
				continue
			if all_pieces[column][row].is_column_bomb:
				all_pieces[column][row].matched = true
				match_pieces_in_column(column)
			if all_pieces[column][row].is_row_bomb:
				all_pieces[column][row].matched = true
				match_pieces_in_row(row)
			if all_pieces[column][row].is_adjacent_bomb:
				all_pieces[column][row].matched = true
				match_adjacent_pieces(column, row)

			matched_and_dim(all_pieces[column][row])
			add_to_array(Vector2(column, row))


func clear_board():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null or is_sinker(column, row):
				continue
			matched_and_dim(all_pieces[column][row])
#			add_to_array(Vector2(column, row))


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
			rand.move(grid_to_pixel(column, row))
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


func add_to_array(value, traget_array = current_matches):
	if !traget_array.has(value):
		traget_array.append(value)


func copy_array(array):
	var copy = make_2d_array()
	for column in width:
		for row in height:
			copy[column][row] = array[column][row]
	return copy

func switch_pieces(place, direction, array):
	if !is_in_grid(place.x, place.y) or !is_in_grid(place.x + direction.x, place.y + direction.y):
		return
	if is_fill_restricted_at(place) or is_fill_restricted_at(place + direction):
		return
	var temp = array[place.x + direction.x][place.y + direction.y]
	array[place.x + direction.x][place.y + direction.y] = array[place.x][place.y]
	array[place.x][place.y] = temp


func switch_and_check(place, direction, array):
	switch_pieces(place, direction, array)
	if find_matches(true, array):
		switch_pieces(place, direction, array)
		return true
	switch_pieces(place, direction, array)
	return false


func store_info(first_piece, other_piece, place, direction):
	piece_one =  first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


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
	if  lock_spaces.has(place):
		return true
	return false
	
	
# Coordinate transformations
func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(pixel_x, pixel_y):
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
		if current_sinkers[i].position == grid_to_pixel(column, row):
			return true
	return false


func matched_and_dim(item):
	item.matched =  true
	item.dim()


func game_over():
	emit_signal("game_over")
	state = WAIT


# Signals
func _on_destroy_timer_timeout():
	destroy_matched()


func _on_collapse_timer_timeout():
	collapse_columns()


func _on_refill_timer_timeout():
	refill_columns()


# Obstacle signals
func _on_lock_holder_lock_destroyed(place, value):
	for i in range(lock_spaces.size() -1,  -1, -1):
		if lock_spaces[i] == place:
			lock_spaces.remove(i)


func _on_concrete_holder_concrete_destroyed(place, value):
	for i in range(concrete_spaces.size() -1,  -1, -1):
		if concrete_spaces[i] == place:
			concrete_spaces.remove(i)


func _on_slime_holder_slime_destroyed(place, value):
	damaged_slime = true
	for i in range(slime_spaces.size() -1,  -1, -1):
		if slime_spaces[i] == place:
			slime_spaces.remove(i)


func _on_Timer_timeout():
	current_counter_value -= 1
	emit_signal("counter_changed")
	if current_counter_value  == 0:
		game_over()
		$Timer.stop()


func _on_GoalHolder_game_won():
	state = WON


func _on_IceHolder_ice_destroyed(place, value):
	for i in range(ice_spaces.size() -1,  -1, -1):
		if ice_spaces[i] == place:
			ice_spaces.remove(i)



func _on_IcyHolder_destroyed(place, value):
	for i in range(ice_spaces.size() -1,  -1, -1):
		if ice_spaces[i] == place:
			ice_spaces.remove(i)
