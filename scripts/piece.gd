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

var row: int setget set_row, get_row
var column: int setget set_column, get_column

var move_tween
var wiggle_tween
var matched = false

# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = $move_tween


func move(target):
	move_tween.interpolate_property(self, "position", position, target, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT )
	move_tween.start()

func wiggle(direction):
	match direction:
		Vector2(1, 0):
			$AnimationPlayer.play("wiggle_left")
		Vector2(-1, 0):
			$AnimationPlayer.play("wiggle_right")
		Vector2(0, 1):
			$AnimationPlayer.play("wiggle_down")
		Vector2(0, -1):
			$AnimationPlayer.play("wiggle_up")


func set_row(new_value):
	row = new_value


func get_row():
	return row


func set_column(new_value):
	column= new_value


func get_column():
	return column


func dim():
	$Sprite.modulate.a = 0.75


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
