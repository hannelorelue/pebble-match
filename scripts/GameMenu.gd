extends Control

signal read_sound

func _ready():
	#$Settings.set_offset(Vector2(576, 0))
	emit_signal("read_sound")


func _on_mainMenu_play_pressed():
	Global.goto_scene("res://scenes/LevelSelection.tscn")
	pass # Replace with function body.


func _on_mainMenu_settings_pressed():
	$mainMenu.slide_out()
	$Settings.slide_in()
	pass # Replace with function body.


func _on_mainMenu_credits_pressed():
	$mainMenu.slide_out()
	$Credits.slide_in()
	pass # Replace with function body.


func _on_Credits_back_Button_pressed():
	$Credits.slide_out()
	$mainMenu.slide_in()
	pass # Replace with function body.


func _on_HighScores_back_Button_pressed():
	$HighScores.slide_out()
	$mainMenu.slide_in()
	pass # Replace with function body.


func _on_mainMenu_highscore_pressed():
	$mainMenu.slide_out()
	$HighScores.slide_in()


func _on_Settings_back_Button_pressed():
	$Settings.slide_out()
	$mainMenu.slide_in()
