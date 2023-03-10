extends Node2D

signal lock_destroyed

var lock_pieces = []
var lock = preload("res://scenes/lock.tscn")

export (int) var width
export (int) var height

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func damage(bord_position):
	if lock_pieces.size() > 0:
		if lock_pieces[bord_position.x][bord_position.y] != null:
			lock_pieces[bord_position.x][bord_position.y].take_damage(1)
			if lock_pieces[bord_position.x][bord_position.y].health <= 0:
				lock_pieces[bord_position.x][bord_position.y].queue_free()
				lock_pieces[bord_position.x][bord_position.y] = null
				emit_signal("lock_destroyed", bord_position)


func make(lock_positions_array):
	if lock_positions_array == null:
		return

	if lock_pieces.size() == 0:
		lock_pieces = make_2d_array()
		
	for i in lock_positions_array.size():
		var current = lock.instance()
		var pos = lock_positions_array[i]
		add_child(current)
		current.position = Vector2(pos.x  * 64 + 64, -pos.y * 64 + 800)
		lock_pieces[pos.x][pos.y] = current
