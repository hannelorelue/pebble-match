extends "res://scenes/menu.gd"


func _on_ContinueButton_pressed():
	get_tree().change_scene("res://scenes/LevelSelection.tscn")


func _on_GoalHolder_game_won():
	slide_in()
