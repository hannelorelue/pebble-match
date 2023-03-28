extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func _on_BackButton_pressed():
	Global.goto_scene("res://scenes/GameMenu.tscn")
	#get_tree().change_scene("res://scenes/GameMenu.tscn")
