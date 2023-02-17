extends Node2D

# State Machine

enum {wait, move}
var state

# Variables
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset
export (int) var y_offset

export (PoolVector2Array) var empty_spaces
export (PoolVector2Array) var ice_spaces
export (PoolVector2Array) var lock_spaces
export (PoolVector2Array) var concrete_spaces

# Obstical signals
signal make_ice
signal damage_ice
signal make_lock
signal damage_lock
signal make_concrete
signal damage_concrete


var piece_pool = [
	preload("red.tscn"),
	preload("pink.tscn"),
	preload("orange.tscn"),
	preload("green.tscn"),
	preload("blue.tscn"),
	preload("black.tscn"),
]

var all_pieces = []

var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false
var 	piece_one 
var piece_two 
var last_place
var last_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	spawn_ice()
	spawn_lock()
	spawn_concrete()


func _process(delta):
	if state == move:
		touch_input()


func restricted_fill(place):
	if is_in_array(empty_spaces, place):
		return true	
	if is_in_array(concrete_spaces, place):
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


func remove_from_array(array, item):
		for i in array.size():
			if array[i] == item:
				array.remove(i)

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


func spawn_ice():
	for i in ice_spaces.size():
		emit_signal("make_ice", ice_spaces[i])


func spawn_lock():
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i])


func spawn_concrete():
	for i in concrete_spaces.size():
		emit_signal("make_concrete", concrete_spaces[i])


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
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
	elif abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
			
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
			if !find_matches():
				yield(temp_timer, "timeout")
				swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
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
							found_match = true
				
				if row > 0 and row < height - 1:
					if all_pieces[column][row - 1] != null and all_pieces[column][row + 1] != null:
						if all_pieces[column][row - 1].color == current_color and all_pieces[column][row + 1].color == current_color:
							matched_and_dim(all_pieces[column][row])
							matched_and_dim(all_pieces[column][row - 1])
							matched_and_dim(all_pieces[column][row + 1])
							found_match = true
	if found_match: 
		get_parent().get_node("destroy_timer").start()
	else:
		state = move
	return found_match


func matched_and_dim(item):
	item.matched =  true
	item.dim()


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
			find_matches()


func store_info(first_piece, other_piece, place, direction):
	piece_one =  first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	


func destroy_matched():
	for column in width:
		for row in height:
			if all_pieces[column][row] != null:
				if all_pieces[column][row].matched:
					damage_special(column, row)
					all_pieces[column][row].queue_free()
					all_pieces[column][row] = null
	get_parent().get_node("collapse_timer").start()


func damage_special(column, row):
	emit_signal("damage_ice", Vector2(column, row))
	emit_signal("damage_lock", Vector2(column, row))
	check_concrete(column, row)


func check_concrete(column, row):
	if column < width - 1:
		emit_signal("damage_concrete", Vector2(column + 1, row))
	if column > 0:
		emit_signal("damage_concrete", Vector2(column - 1, row))
	if row < height - 1:
		emit_signal("damage_concrete", Vector2(column, row + 1))
	if row > 0:
		emit_signal("damage_concrete", Vector2(column, row - 1))
		
		
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
	find_matches()


func _on_destroy_timer_timeout():
	destroy_matched()


func _on_collapse_timer_timeout():
	collapse_columns()


func _on_refill_timer_timeout():
	refill_columns()


func _on_lock_holder_remove_lock(place):
	for i in lock_spaces.size():
		if lock_spaces[i] == place:
			lock_spaces.remove(i)


func _on_concrete_holder_remove_concrete(place):
	for i in concrete_spaces.size():
		if concrete_spaces[i] == place:
			concrete_spaces.remove(i)
