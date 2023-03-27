extends TextureRect

signal game_paused


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Pause_pressed():
	emit_signal("game_paused")
	get_tree().paused  = true
