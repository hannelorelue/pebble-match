extends Node2D

export (int) var level
export (String) var level_to_load
export (bool) var is_enabled
export (bool) var is_score_beaten

export (Texture) var blocked_texture
export (Texture) var open_texture
export (Texture) var goal_met
export (Texture) var goal_not_met

onready var level_label = $TextureButton/Label
onready var button = $TextureButton
onready var star = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()
	pass # Replace with function body.

func setup():
	level_label.text = String(level)
	if is_enabled:
		button.texture_normal = open_texture
	else:
		button.texture_normal = blocked_texture
	if is_score_beaten:
		star.texture = goal_met
	else:
		star.texture = goal_not_met


func _on_TextureButton_pressed():
	if is_enabled:
		get_tree().change_scene(level_to_load)

