extends Node2D

signal ice_destroyed

export (Resource) var scene

var value = "ice"
var width = Global.width
var height  = Global.height

var ice_pieces = []


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func damage(bord_position):
	if ice_pieces.size() <= 0:
		return
	if ice_pieces[bord_position.x][bord_position.y] == null:
		return
	ice_pieces[bord_position.x][bord_position.y].take_damage(1)
	if ice_pieces[bord_position.x][bord_position.y].health <= 0:
		ice_pieces[bord_position.x][bord_position.y].queue_free()
		ice_pieces[bord_position.x][bord_position.y] = null
		emit_signal("ice_destroyed", bord_position, value)


func make(ice_positions_array):
	if ice_positions_array == null:
		return

	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array()
		
	for i in ice_positions_array.size():
		var current = scene.instance()
		var pos = ice_positions_array[i]
		current.position = Vector2(pos.x  * 64 + 64, -pos.y * 64 + 800)
		ice_pieces[pos.x][pos.y] = current
		add_child(current)

