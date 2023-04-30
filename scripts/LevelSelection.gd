extends CanvasLayer

var page 


func init(background, level_dict):
	$LevelBackground.texture = background
	for item in level_dict:
		var new_button  = load("res://scenes/LevelButton.tscn").new()
		new_button.level = level_dict[item]["level"]
		new_button.position = level_dict[item]["position"]
		$LevelBackground.add_child(new_button)
	pass


func _on_Button_pressed():
	Global.goto_scene("res://scenes/GameMenu.tscn")
	AudioManager.play_click()


func _on_NextButton_pressed() -> void:
	pass # Replace with function body.
