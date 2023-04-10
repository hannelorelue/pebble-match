extends CanvasLayer

signal back_Button_pressed

func _ready():
	$MarginContainer/VBoxContainer/MusicCheckBox.pressed = ConfigManager.music_on
	$MarginContainer/VBoxContainer/SoundCheckBox.pressed = ConfigManager.sound_on

func slide_in():
	$AnimationPlayer.play("slide_in")

func slide_out():
	$AnimationPlayer.play_backwards("slide_in")



func _on_MusicCheckBox_toggled(button_pressed):
	ConfigManager.music_on = button_pressed
	ConfigManager.save_config()
	AudioManager.set_volume()
	AudioManager.play_random_music()


func _on_SoundCheckBox_toggled(button_pressed):
	ConfigManager.sound_on = button_pressed
	ConfigManager.save_config()
	AudioManager.set_volume()
	AudioManager.play_fixed_sound(4)


func _on_BackButton_pressed():
	emit_signal("back_Button_pressed")
