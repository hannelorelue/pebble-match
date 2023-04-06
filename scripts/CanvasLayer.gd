extends "res://scripts/menu.gd"

signal play_pressed
signal settings_pressed

func _ready():
	$AnimationPlayer.play("StartButtonWiggle")


func _on_Button1_pressed():
	emit_signal("play_pressed")


func _on_Button2_pressed():
	emit_signal("settings_pressed")


func _on_StartButton_pressed():
	emit_signal("play_pressed")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "slide_in":
		$AnimationPlayer.play("StartButtonWiggle")
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	emit_signal("settings_pressed")
	pass # Replace with function body.
