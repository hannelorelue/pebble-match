extends "res://scenes/menu.gd"

signal sound_change
signal back_button

func _on_Button1_pressed():
	emit_signal("sound_change")


func _on_Button2_pressed():
	emit_signal("back_button")

#
#func _on_MainMenu_settings_pressed():
#	self.slide_in()
#
