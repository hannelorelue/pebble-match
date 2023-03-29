extends Node

export (Texture) var goal_texture
export (int) var max_needed
export(String) var  goal_string

var collected = 0
var is_goal_met = false


func check_goal(goal_type):
	if goal_type == goal_string:
		update_goal()


func update_goal():
	if collected < max_needed:
		collected += 1
	if collected == max_needed:
		if !is_goal_met:
			is_goal_met = true
