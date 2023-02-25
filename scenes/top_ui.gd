extends TextureRect

onready var score_label = $MarginContainer/HBoxContainer/ScoreLabel
var current_score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	_on_grid_update_score(current_score)


func _on_grid_update_score(amount):
	current_score += amount
	score_label.text = String(current_score)
	pass # Replace with function body.
