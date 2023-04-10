extends TextureRect

signal game_won

export (PackedScene) var goal_ui
onready var score_label = $MarginContainer/HBoxContainer/VBoxContainer/ScoreLabel
onready var move_label = $MarginContainer/HBoxContainer/VBoxContainer2/MoveLabel
onready var counter_label = $MarginContainer/HBoxContainer/VBoxContainer2/CounterLabel
onready var score_bar = $MarginContainer/HBoxContainer/VBoxContainer/TextureProgress
onready var goal_container = $MarginContainer/HBoxContainer/VBoxContainer3/HBoxContainer

var current_score = 0
var current_count = 0
var is_game_won = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_grid_update_score(current_score)


func setup_score_bar(max_score):
	score_bar.max_value = max_score


func update_score_bar():
	score_bar.value = current_score


func make_goal(type, new_max):
	if new_max == 0:
		return
	var current = goal_ui.instance()
	goal_container.add_child(current)
	current.set_goal(type, new_max)


func update_goals(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal(goal_type)
	check_win_conditions()


func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)
	check_win_conditions()


func check_win_conditions():
	if are_all_goals_met():
		emit_signal("game_won")


func are_all_goals_met():
	for i in goal_container.get_child_count():
		if !goal_container.get_child(i).is_goal_met:
			return false
	return true


func _on_grid_update_score(amount):
	current_score = amount
	update_score_bar()
	score_label.text = String(current_score)


func _on_grid_counter_changed(amount = -1):
	current_count += amount
	counter_label.text = String(current_count)


func _on_grid_set_max_score(max_score):
	setup_score_bar(max_score)


func _on_grid_check_goal(goal_type):
	update_goals(goal_type)


func _on_IcyHolder_destroyed(_place, goal_type):
	update_goals(goal_type)


func _on_SlimeHolder_destroyed(_place, goal_type):
	update_goals(goal_type)


func _on_ConcreteHolder_destroyed(_place, goal_type):
	update_goals(goal_type)


func _on_LockHolder_destroyed(_place, goal_type):
	update_goals(goal_type)
