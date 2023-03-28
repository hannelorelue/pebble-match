extends Control

signal read_sound

func _ready():
	$MainMenu.slide_in()
	$Settings.set_offset(Vector2(576, 0))
	emit_signal("read_sound")


func _on_MainMenu_settings_pressed():
	$MainMenu.slide_out()
	$Settings.slide_in()


func _on_Settings_back_button():
	$Settings.slide_out()
	$MainMenu.slide_in()


func _on_MainMenu_play_pressed():
	Global.goto_scene("res://scenes/LevelSelection.tscn")

