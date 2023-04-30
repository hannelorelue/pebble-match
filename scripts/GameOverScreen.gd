extends "res://scripts/menu.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().paused = false
	Global.goto_scene("res://scenes/LevelSelection.tscn")
	#get_tree().change_scene("res://scenes/LevelSelection.tscn")


func _on_Restart_pressed():
	var level = get_parent().get_level()
	Global.goto_level(level)


func _on_grid_game_over():
	slide_in()
