extends "res://scripts/menu.gd"

signal play_pressed
signal settings_pressed
signal credits_pressed
signal highscore_pressed

func _ready():
	$AnimationPlayer.play("StartButtonWiggle")


func _on_Button1_pressed():
	emit_signal("play_pressed")
	AudioManager.play_click()


func _on_Button2_pressed():
	emit_signal("settings_pressed")
	AudioManager.play_click()


func _on_StartButton_pressed():
	emit_signal("play_pressed")
	AudioManager.play_click()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "slide_in":
		$AnimationPlayer.play("StartButtonWiggle")


func _on_SettingsButton_pressed():
	emit_signal("settings_pressed")
	AudioManager.play_click()


func _on_Credits_pressed():
	emit_signal("credits_pressed")
	AudioManager.play_click()


func _on_HighscoresButton_pressed():
	emit_signal("highscore_pressed")
	AudioManager.play_click()
