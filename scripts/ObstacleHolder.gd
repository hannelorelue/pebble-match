extends Node2D

signal destroyed

export (Resource) var scene
export (String) var value = "obstacle"

var obstacle_pieces = []
var width = Global.width
var height  = Global.height
var offset =  Global.offset
var x_start =  Global.x_start
var y_start =  Global.y_start

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func damage(bord_position):
	if obstacle_pieces.size() > 0:
		var current = obstacle_pieces[bord_position.x][bord_position.y]
		if current == null:
			return
		obstacle_pieces[bord_position.x][bord_position.y].take_damage(1)
		if obstacle_pieces[bord_position.x][bord_position.y].health <= 0:
			obstacle_pieces[bord_position.x][bord_position.y].queue_free()
			obstacle_pieces[bord_position.x][bord_position.y] = null
			emit_signal("destroyed", bord_position, value)


func make(obstacle_positions_array):
	if obstacle_positions_array == null:
		return

	if obstacle_pieces.size() == 0:
		obstacle_pieces = make_2d_array()
		
	for i in obstacle_positions_array.size():
		var current = scene.instance()
		var pos = obstacle_positions_array[i]
		add_child(current)
		current.position = Vector2(pos.x * offset + x_start, -pos.y * offset + y_start)
		obstacle_pieces[pos.x][pos.y] = current
