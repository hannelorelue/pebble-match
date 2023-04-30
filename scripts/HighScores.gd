extends CanvasLayer

onready var grid = $MarginContainer/VBoxContainer/GridContainer
signal back_Button_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	var level_info = GameDataManager.level_info
	for level in level_info:
		var level_label = Label.new()
		level_label.text = String(level)
		grid.add_child(level_label)
		var score_label = Label.new()
		score_label.text = String(level_info[level]["high_score"])
		grid.add_child(score_label)
		var date_label = Label.new()
		date_label.text = level_info[level]["date"]
		grid.add_child(date_label)
	pass # Replace with function body.


func slide_in():
	$AnimationPlayer.play("slide_in")


func slide_out():
	$AnimationPlayer.play_backwards("slide_in")


func _on_BackButton_pressed():
	emit_signal("back_Button_pressed")
	AudioManager.play_click()
	pass # Replace with function body.
