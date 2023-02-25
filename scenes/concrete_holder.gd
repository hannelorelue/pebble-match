extends Node2D

signal remove_concrete

var concrete_pieces = []
var concrete = preload("res://scenes/concrete.tscn")

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


func _on_grid_damage_concrete(bord_position):
	if concrete_pieces.size() > 0:
		if concrete_pieces[bord_position.x][bord_position.y] != null:
			concrete_pieces[bord_position.x][bord_position.y].take_damage(1)
			if concrete_pieces[bord_position.x][bord_position.y].health <= 0:
				concrete_pieces[bord_position.x][bord_position.y].queue_free()
				concrete_pieces[bord_position.x][bord_position.y] = null
				emit_signal("remove_concrete", bord_position)


func _on_grid_make_concrete(bord_position):
	if concrete_pieces.size() == 0:
		concrete_pieces = make_2d_array()
	var current = concrete.instance()
	add_child(current)
	current.position = Vector2(bord_position.x  * 64 + 64, -bord_position.y * 64 + 800)
	concrete_pieces[bord_position.x][bord_position.y] = current
