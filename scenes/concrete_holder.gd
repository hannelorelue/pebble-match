extends Node2D

signal concrete_destroyed

var concrete_pieces = []
var concrete = preload("res://scenes/concrete.tscn")
var value = "slime"

var width = Global.width
var height  = Global.height

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
	if concrete_pieces.size() > 0:
		if concrete_pieces[bord_position.x][bord_position.y] != null:
			concrete_pieces[bord_position.x][bord_position.y].take_damage(1)
			if concrete_pieces[bord_position.x][bord_position.y].health <= 0:
				concrete_pieces[bord_position.x][bord_position.y].queue_free()
				concrete_pieces[bord_position.x][bord_position.y] = null
				emit_signal("concrete_destroyed", bord_position, value)


func make(concrete_positions_array):
	if concrete_positions_array == null:
		return
		
	if concrete_pieces.size() == 0:
		concrete_pieces = make_2d_array()
		
	for i in concrete_positions_array.size():
		var current = concrete.instance()
		var pos = concrete_positions_array[i]
		add_child(current)
		current.position = Vector2(pos.x  * 64 + 64, -pos.y * 64 + 800)
		concrete_pieces[pos.x][pos.y] = current
