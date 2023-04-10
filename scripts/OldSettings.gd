extends "res://scripts/menu.gd"

signal sound_change
signal back_button

export (Texture) var sound_on_texture
export (Texture) var sound_off_texture


func change_sound_texture():
	if ConfigManager.sound_on == true:
		$MarginContainer/VBoxContainer/VBoxContainer/Button1.texture_normal = sound_on_texture
	else:
		$MarginContainer/VBoxContainer/VBoxContainer/Button1.texture_normal = sound_off_texture


func _on_Button1_pressed():
	ConfigManager.sound_on = !ConfigManager.sound_on
	change_sound_texture()
	ConfigManager.save_config()
	AudioManager.set_volume()
	AudioManager.play_fixed_sound(0)


func _on_Button2_pressed():
	AudioManager.play_fixed_sound(0)
	emit_signal("back_button")


func _on_GameMenu_read_sound():
	change_sound_texture()
