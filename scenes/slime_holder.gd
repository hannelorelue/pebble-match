extends Node2D

signal remove_slime

var slime_pieces = []
var slime = preload("res://scenes/slime.tscn")

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


func _on_grid_damage_slime(bord_position):
	if slime_pieces.size() > 0:
		if slime_pieces[bord_position.x][bord_position.y] != null:
			slime_pieces[bord_position.x][bord_position.y].take_damage(1)
			if slime_pieces[bord_position.x][bord_position.y].health <= 0:
				slime_pieces[bord_position.x][bord_position.y].queue_free()
				slime_pieces[bord_position.x][bord_position.y] = null
				emit_signal("remove_slime", bord_position)


func _on_grid_make_slime(bord_position):
	if slime_pieces.size() == 0:
		slime_pieces = make_2d_array()
	var current = slime.instance()
	add_child(current)
	current.position = Vector2(bord_position.x  * 64 + 64, -bord_position.y * 64 + 800)
	slime_pieces[bord_position.x][bord_position.y] = current
