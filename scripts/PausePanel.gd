extends "res://scripts/menu.gd"


func _on_Continue_pressed():
	get_tree().paused = false
	slide_out()


func _on_Quit_pressed():
	Global.goto_scene("res://scenes/GameMenu.tscn")
#	get_tree().quit()
#	slide_out()


func _on_bottomUi_game_paused():
	slide_in()
