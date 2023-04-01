extends TextureRect

var current_value := 0
var max_value: int
var goal_value := ""
var goal_texture
onready var goal_label = $VBoxContainer/Label
onready var this_texture = $VBoxContainer/TextureRect

func set_goal_values(new_max, new_texture, new_value):
	this_texture.texture  = new_texture
	max_value = new_max
	goal_value = new_value
	goal_label.text = "" + String(current_value) + " / " + String(max_value) + ""
	
func update_goal_values(goal_type):
	if goal_type == goal_value:
		current_value += 1
		if current_value  <= max_value:
			goal_label.text = "" + String(current_value) + " / " + String(max_value) + ""

