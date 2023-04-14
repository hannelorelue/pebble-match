extends Node2D

export (int) var level
var level_to_load 
export (bool) var is_enabled
export (bool) var is_score_beaten

export (Texture) var blocked_texture
export (Texture) var open_texture
export (Texture) var goal_met
export (Texture) var goal_not_met

onready var level_label = $TextureButton/Label
onready var button = $TextureButton
onready var star_1 = $Sprite
onready var star_2 = $Sprite2
onready var star_3 = $Sprite3


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameDataManager.level_info.has(level):
		is_enabled = GameDataManager.level_info[level]["unlocked"]
	else:
		self.visible = false
		return
	setup()


func setup():
	level_label.text = String(level)
	var no_stars = GameDataManager.level_info[level]["stars_unlocked"]
	if is_enabled:
		button.texture_normal = open_texture
	else:
		button.texture_normal = blocked_texture
	
	match no_stars:
		1:
			star_1.texture = goal_met
			star_2.texture = goal_not_met
			star_3.texture = goal_not_met
		2: 
			star_1.texture = goal_met
			star_2.texture = goal_met
			star_3.texture = goal_not_met
		3: 
			star_1.texture = goal_met
			star_2.texture = goal_met
			star_3.texture = goal_met
		_:
			star_1.texture = goal_not_met
			star_2.texture = goal_not_met
			star_3.texture = goal_not_met


func _on_TextureButton_pressed():
	if is_enabled:
		Global.goto_level(level)
		AudioManager.play_click()
