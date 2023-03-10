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

func damage(bord_position):
	if ice_pieces.size() > 0:
		if ice_pieces[bord_position.x][bord_position.y] != null:
			ice_pieces[bord_position.x][bord_position.y].take_damage(1)
			if ice_pieces[bord_position.x][bord_position.y].health <= 0:
				ice_pieces[bord_position.x][bord_position.y].queue_free()
				ice_pieces[bord_position.x][bord_position.y] = null


func make(ice_positions_array):
	if ice_positions_array == null:
		return

	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array()
		
	for i in ice_positions_array.size():
		var current = ice.instance()
		var pos = ice_positions_array[i]
		add_child(current)
		current.position = Vector2(pos.x  * 64 + 64, -pos.y * 64 + 800)
		ice_pieces[pos.x][pos.y] = current

