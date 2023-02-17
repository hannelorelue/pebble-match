extends Node2D

signal remove_lock

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


func _on_grid_damage_lock(bord_position):
		if lock_pieces[bord_position.x][bord_position.y] != null:
			lock_pieces[bord_position.x][bord_position.y].take_damage(1)
			if lock_pieces[bord_position.x][bord_position.y].health <= 0:
				lock_pieces[bord_position.x][bord_position.y].queue_free()
				lock_pieces[bord_position.x][bord_position.y] = null
				emit_signal("remove_lock", bord_position)


func _on_grid_make_lock(bord_position):
	if lock_pieces.size() == 0:
		lock_pieces = make_2d_array()
	var current = lock.instance()
	add_child(current)
	current.position = Vector2(bord_position.x  * 64 + 64, -bord_position.y * 64 + 800)
	lock_pieces[bord_position.x][bord_position.y] = current
