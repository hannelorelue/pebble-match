extends "res://scripts/menu.gd"


func _on_ContinueButton_pressed():
	Global.goto_scene("res://scenes/LevelSelection.tscn")
	#get_tree().change_scene("res://scenes/LevelSelection.tscn")


func _on_GoalHolder_game_won():
	slide_in()
