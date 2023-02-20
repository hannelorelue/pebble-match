extends Node2D

# State Machine

enum {wait, move}
var state

# Grid Variables
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset
export (int) var y_offset


# Obstacle Variables
export (PoolVector2Array) var empty_spaces
export (PoolVector2Array) var ice_spaces
export (PoolVector2Array) var lock_spaces
export (PoolVector2Array) var concrete_spaces
export (PoolVector2Array) var slime_spaces
var damaged_slime = false

# Obstacle signals
signal make_ice
signal damage_ice
signal make_lock
signal damage_lock
signal make_concrete
signal damage_concrete
signal make_slime
signal damage_slime


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

var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

# Swap back variables
var 	piece_one = null
var piece_two = null
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)
var  move_checked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	spawn_obstacles(ice_spaces, "ice")
	spawn_obstacles(concrete_spaces, "concrete")
	spawn_obstacles(lock_spaces, "lock")
	spawn_obstacles(slime_spaces, "slime")


func _process(delta):
	if state == move:
		touch_input()


func restricted_fill(place):
	if is_in_array(empty_spaces, place):
		return true	
	if is_in_array(concrete_spaces, place):
		return true
	if is_in_array(slime_spaces, place):
		return true
	return false


func restricted_move(place):
	if  is_in_array(lock_spaces, place):
		return true
	return false

func is_in_array(array, item):
	for i in array.size():
		if  array[i] == item:
			return true
	return false


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for column in width:
		for row in height:
			if !restricted_fill(Vector2(column, row)):
				var list = []
				for i in piece_pool.size():
					list.append(i)
				
				var rand = list.pop_at(floor(rand_range(0, list.size())))
				var piece = piece_pool[rand].instance()
				while match_at(column, row, piece.color) and list.size() > 1:
					rand = list.pop_at(floor(rand_range(0, list.size())))
					piece = piece_pool[rand].instance()
					
				add_child(piece)
				piece.position = grid_to_pixel(column, row)
				all_pieces[column][row] = piece


func spawn_obstacles(obstacle_array, name):
	if obstacle_array !=null:
		for i in obstacle_array.size():
			emit_signal("make_" + name, obstacle_array[i])


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
				damaged_slime = true
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))
				state = move

		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
			if !find_matches():
				damaged_slime = true
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
				state = move

	elif abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
			if !find_matches():
				damaged_slime = true
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
				state = move
			
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
			if !find_matches():
				damaged_slime = true
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
				state = move
	else:
		pass


# Transformations
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
	if column >= 0 and column < width:
		if row >= 0 and  row < height:
			return true
	return false	

func match_at(column, row, color):
	if column > 1:
		if all_pieces[column - 1][row] != null and all_pieces[column - 2][row] != null:
			if all_pieces[column - 1][row].color == color and all_pieces[column - 2][row].color == color:
				return true
	if row > 1:
		if all_pieces[column][row - 1] != null and all_pieces[column][row - 2] != null:
			if all_pieces[column][row - 1].color == color and all_pieces[column][row - 2].color == color:
				return true


func find_matches():
	var found_match = false
	for column in width:
		for row in height:
			if all_pieces[column][row] != null:
				var current_color = all_pieces[column][row].color
				if column > 0 and column < width - 1:
					if all_pieces[column - 1][row] != null and all_pieces[column + 1][row] != null:
						if all_pieces[column - 1][row].color == current_color and all_pieces[column + 1][row].color == current_color:
							matched_and_dim(all_pieces[column][row])
							matched_and_dim(all_pieces[column - 1][row])
							matched_and_dim(all_pieces[column + 1][row])
							
							add_to_array(Vector2(column, row))
							add_to_array(Vector2(column - 1, row))
							add_to_array(Vector2(column + 1, row))
							found_match = true
				
				if row > 0 and row < height - 1:
					if all_pieces[column][row - 1] != null and all_pieces[column][row + 1] != null:
						if all_pieces[column][row - 1].color == current_color and all_pieces[column][row + 1].color == current_color:
							matched_and_dim(all_pieces[column][row])
							matched_and_dim(all_pieces[column][row - 1])
							matched_and_dim(all_pieces[column][row + 1])
							
							add_to_array(Vector2(column, row))
							add_to_array(Vector2(column, row -  1))
							add_to_array(Vector2(column, row + 1))
							found_match = true
	if found_match: 
		get_parent().get_node("destroy_timer").start()
	else:
		state = move
	return found_match


func matched_and_dim(item):
	item.matched =  true
	item.dim()


func find_bombs():
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
			if this_row== current_row and current_color == this_color:
				row_matched +=1
		if col_matched == 4:
			print("column bomb")
		if row_matched == 4:
			print("row bomb")
		if col_matched == 3 and row_matched == 3:
			print("adjacent bomb")
		if col_matched >= 5 or row_matched >= 5:
			print("color bomb")
	pass

func add_to_array(value, traget_array = current_matches):
	if !traget_array.has(value):
		traget_array.append(value)


func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null and other_piece != null:
		if !restricted_move(Vector2(column, row)) and !restricted_move(Vector2(column, row) + direction):
			store_info(first_piece, other_piece, Vector2(column, row), direction)
			state = wait
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
			first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
			other_piece.move(grid_to_pixel(column, row))
			if !move_checked:
				find_matches()


func swap_back():
	if piece_one != null and piece_two  != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move
	move_checked = false


func store_info(first_piece, other_piece, place, direction):
	piece_one =  first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


func destroy_matched():
	find_bombs()
	var was_matched = false
	for column in width:
		for row in height:
			if all_pieces[column][row] != null:
				if all_pieces[column][row].matched:
					damage_special(column, row)
					was_matched = true
					all_pieces[column][row].queue_free()
					all_pieces[column][row] = null
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else: 
		swap_back()
	current_matches.clear()


func damage_special(column, row):
	emit_signal("damage_ice", Vector2(column, row))
	emit_signal("damage_lock", Vector2(column, row))
	check_special(column, row, "concrete")
	check_special(column, row, "slime")


func check_special(column, row, name):
	if column < width - 1:
		emit_signal("damage_" + name, Vector2(column + 1, row))
	if column > 0:
		emit_signal("damage_" + name, Vector2(column - 1, row))
	if row < height - 1:
		emit_signal("damage_" + name, Vector2(column, row + 1))
	if row > 0:
		emit_signal("damage_" + name, Vector2(column, row - 1))


func collapse_columns():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null and !restricted_fill(Vector2(column, row)):
				for k in range(row + 1, height):
					if all_pieces[column][k] != null:
						all_pieces[column][k].move(grid_to_pixel(column, row))
						all_pieces[column][row] = all_pieces[column][k]
						all_pieces[column][k] = null
						break
	get_parent().get_node("refill_timer").start()


func refill_columns():
	for column in width:
		for row in height:
			if all_pieces[column][row] == null and !restricted_fill(Vector2(column, row)):
				var list = []
				for i in piece_pool.size():
					list.append(i)
				
				var rand = list.pop_at(floor(rand_range(0, list.size())))
				var piece = piece_pool[rand].instance()
				while match_at(column, row, piece.color) and list.size() > 1:
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
			if all_pieces[column][row] != null and match_at(column, row, all_pieces[column][row].color):
				find_matches()
				get_parent().get_node("destroy_timer").start()
				return
	state = move
	move_checked = false
	if !damaged_slime:
		generate_slime()
	damaged_slime = false

# returns a random non-slime neighbor
func find_normal_tile(column, row):
	var list = []
	list.append(Vector2(column + 1, row))
	list.append(Vector2(column  - 1, row))
	list.append(Vector2(column, row  + 1))
	list.append(Vector2(column, row  - 1))
	
	for i in range( list.size() -1,  -1, -1):
		if !is_in_grid(list[i].x, list[i].y) or all_pieces[list[i].x][list[i].y] == null:
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
			if neighbor != null:
				all_pieces[neighbor.x][neighbor.y].queue_free()
				all_pieces[neighbor.x][neighbor.y] = null
				slime_spaces.append(Vector2(neighbor.x, neighbor.y))
				emit_signal("make_slime", Vector2(neighbor.x, neighbor.y))
				slime_made = true
	damaged_slime = false

# Signals
func _on_destroy_timer_timeout():
	destroy_matched()


func _on_collapse_timer_timeout():
	collapse_columns()


func _on_refill_timer_timeout():
	refill_columns()


func _on_lock_holder_remove_lock(place):
	for i in range(lock_spaces.size() -1,  -1, -1):
		if lock_spaces[i] == place:
			lock_spaces.remove(i)


func _on_concrete_holder_remove_concrete(place):
	for i in range( concrete_spaces.size() -1,  -1, -1):
		if concrete_spaces[i] == place:
			concrete_spaces.remove(i)


func _on_slime_holder_remove_slime(place):
	damaged_slime = true
	for i in range(slime_spaces.size() -1,  -1, -1):
		if slime_spaces[i] == place:
			slime_spaces.remove(i)
