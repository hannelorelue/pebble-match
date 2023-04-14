extends TextureRect

signal game_paused
signal AddMovesBoost_pressed
signal ShuffleBoost_pressed
signal DiamondBoost_pressed

export (Texture) var time_texture

onready var add_moves_button = $MarginContainer/HBoxContainer/AddMovesBoost
onready var shuffle_button = $MarginContainer/HBoxContainer/ShuffleBoost
onready var diamond_button = $MarginContainer/HBoxContainer/DiamondBoost

# Called when the node enters the scene tree for the first time.
func _ready():
	add_moves_button.visible = false
	shuffle_button.visible = false
	diamond_button.visible = false
	pass # Replace with function body.


func _on_Pause_pressed():
	emit_signal("game_paused")
	get_tree().paused  = true


func _on_AddMovesBoost_pressed():
	emit_signal("AddMovesBoost_pressed")


func _on_ShuffleBoost_pressed():
	emit_signal("ShuffleBoost_pressed")


func _on_DiamondBoost_pressed():
	emit_signal("DiamondBoost_pressed")


func _on_grid_max_score_reached() -> void:
	add_moves_button.visible = true
	shuffle_button.visible = true
	diamond_button.visible = true
	pass # Replace with function body.


func _on_grid_max_score_not_reached() -> void:
	add_moves_button.visible = false
	shuffle_button.visible = false
	diamond_button.visible = false
	pass # Replace with function body.
