extends Node

func play_click_noise():
	AudioManager.play_fixed_sound(1)


func play_random_noise():
	AudioManager.play_random_sound()


func _on_grid_play_sound():
	play_click_noise()
