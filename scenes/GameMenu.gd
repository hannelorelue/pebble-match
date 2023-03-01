extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func _ready():
	$MainMenu.slide_in()
	$Settings.set_offset(Vector2(576, 0))


func _on_MainMenu_settings_pressed():
	$MainMenu.slide_out()
	$Settings.slide_in()


func _on_Settings_back_button():
	$Settings.slide_out()
	$MainMenu.slide_in()

