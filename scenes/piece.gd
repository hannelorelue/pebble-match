extends Node2D

export (String) var  color

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
	
