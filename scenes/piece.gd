extends Node2D

export (String) var color

export (Texture) var row_texture
export (Texture) var column_texture
export (Texture) var adjacent_texture
export (Texture) var prism_texture

var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false
var is_color_bomb = false


var move_tween
var matched = false

# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = $move_tween
	pass # Replace with function body.

func move(target):
	move_tween.interpolate_property(self, "position", position, target, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT )
	move_tween.start()


func dim():
	$Sprite.modulate.a = 0.5


func make_column_bomb():
	is_column_bomb = true
	$Sprite.texture = column_texture
	$Sprite.modulate = Color(1,1,1,1)


func make_row_bomb():
	is_row_bomb = true
	$Sprite.texture = row_texture
	$Sprite.modulate = Color(1,1,1,1)


func make_adjacent_bomb():
	is_adjacent_bomb = true
	$Sprite.texture = adjacent_texture
	$Sprite.modulate = Color(1,1,1,1)


func make_color_bomb():
	is_color_bomb = true
	$Sprite.texture = prism_texture
	$Sprite.modulate = Color(1,1,1,1)
	color = "Color"
