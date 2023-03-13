extends TextureRect

export (PackedScene) var goal_ui
onready var score_label = $MarginContainer/HBoxContainer/VBoxContainer/ScoreLabel
onready var counter_label = $MarginContainer/HBoxContainer/CounterLabel
onready var score_bar = $MarginContainer/HBoxContainer/VBoxContainer/TextureProgress
onready var goal_container = $MarginContainer/HBoxContainer/HBoxContainer

var current_score = 0
var current_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_grid_update_score(current_score)


func setup_score_bar(max_score):
	score_bar.max_value =  max_score


func update_score_bar():
	score_bar.value =  current_score


func make_goal(new_max, new_texture, new_value):
	var current = goal_ui.instance()
	goal_container.add_child(current)
	current.set_goal_values(new_max, new_texture, new_value)

func update_goals(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)


func _on_grid_update_score(amount):
	current_score += amount
	update_score_bar()
	score_label.text = String(current_score)


func _on_grid_counter_changed(amount = -1):
	current_count += amount
	counter_label.text = String(current_count)


func _on_grid_set_max_score(max_score):
	setup_score_bar(max_score)


func _on_GoalHolder_create_goals_started(new_max, new_texture, new_value):
	make_goal(new_max, new_texture, new_value)


func _on_grid_check_goal(goal_type):
	update_goals(goal_type)


func _on_IceHolder_ice_destroyed(place, goal_type):
	update_goals(goal_type)

