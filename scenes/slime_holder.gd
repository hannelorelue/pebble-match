extends Node2D

signal slime_destroyed

export (Resource) var scene
var value = "slime"
var slime_pieces = []

#var slime = preload("res://scenes/slime.tscn")

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
	if slime_pieces != null :
		if slime_pieces[bord_position.x][bord_position.y] != null:
			slime_pieces[bord_position.x][bord_position.y].take_damage(1)
			if slime_pieces[bord_position.x][bord_position.y].health <= 0:
				slime_pieces[bord_position.x][bord_position.y].queue_free()
				slime_pieces[bord_position.x][bord_position.y] = null
				emit_signal("slime_destroyed", bord_position, value)


func make(slime_positions_array):
	if slime_positions_array == null:
		return
		
	if slime_pieces.size() == 0:
		slime_pieces = make_2d_array()
		
	for i in slime_positions_array.size():
		var current = scene.instance()
		var pos = slime_positions_array[i]
		add_child(current)
		current.position = Vector2(pos.x  * 64 + 64, -pos.y * 64 + 800)
		slime_pieces[pos.x][pos.y] = current
