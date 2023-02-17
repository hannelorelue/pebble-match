extends Node2D

var ice_pieces = []

export (int) var width
export (int) var height

var ice = preload("res://scenes/ice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#ice_pieces = get_tree().current_scene.get_node("grid").make_2d_array()
	pass # Replace with function body.

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func _on_grid_damage_ice(bord_position):
	if ice_pieces[bord_position.x][bord_position.y] != null:
		ice_pieces[bord_position.x][bord_position.y].take_damage(1)
		if ice_pieces[bord_position.x][bord_position.y].health <= 0:
			ice_pieces[bord_position.x][bord_position.y].queue_free()
			ice_pieces[bord_position.x][bord_position.y] = null


func _on_grid_make_ice(bord_position):
	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array()
	var current = ice.instance()
	add_child(current)
	current.position = Vector2(bord_position.x  * 64 + 64, -bord_position.y * 64 + 800)
	ice_pieces[bord_position.x][bord_position.y] = current

