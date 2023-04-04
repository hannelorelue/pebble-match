extends Node2D

export (String) var color

onready var sprite = $Sprite
onready var diamond_sprite = $DiamondSprite

var row: int setget set_row, get_row
var column: int setget set_column, get_column

var type := ""
var move_tween
var wiggle_tween
var matched = false
var is_sinker = false
var is_color_bomb = false


# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = $move_tween


func init(Type):
	color = Type
	match color:
		"CINNABARIT":
			sprite.region_rect = Rect2( 0, 0, 32, 32 )
		"COAL":
			sprite.region_rect = Rect2( 32, 0, 32, 32 )
		"QUARTZ":
			sprite.region_rect = Rect2( 64, 0, 32, 32 )
		"SPHALERITE":
			sprite.region_rect = Rect2( 96, 0, 32, 32 )
		"COPPER":
			sprite.region_rect = Rect2( 0, 32, 32, 32 )
		"IRON":
			sprite.region_rect = Rect2( 32, 32, 32, 32 )
		"ROCK":
			sprite.region_rect = Rect2( 64, 32, 32, 32 )
		_:
			sprite.region_rect = Rect2( 96, 32, 32, 32 )
			
	if is_sinker:
		match color:
			"PINK":
				sprite.region_rect = Rect2( 0, 64, 32, 32 )
			"GREEN":
				sprite.region_rect = Rect2( 32, 64, 32, 32 )
			"RED":
				sprite.region_rect = Rect2( 64, 64, 32, 32 )
			"BLUE":
				sprite.region_rect = Rect2( 96, 64, 32, 32 )


func move(target):
	move_tween.interpolate_property(self, "position", position, target, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT )
	move_tween.start()

func wiggle(direction):
	var parent = self.get_parent()
	parent.move_child(self, parent.get_child_count())
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
	column = new_value


func get_column():
	return column


func dim():
	sprite.modulate.a = 0.75


func make_color_bomb():
	is_color_bomb = true
	sprite.visible = false
	diamond_sprite.visible = true
	diamond_sprite.playing = true
	#sprite.texture = prism_texture
	#sprite.modulate = Color(1,1,1,1)
	color = "Color"
