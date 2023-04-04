extends TextureRect

onready var goal_label = $VBoxContainer/Label
onready var texture_rect = $VBoxContainer/TextureRect
var current_value := 0
var max_value: int
var goal_type := ""
var goal_texture
var is_goal_met = false


export (Texture) var cinnabarit
export (Texture) var coal
export (Texture) var quartz
export (Texture) var sphalerite
export (Texture) var copper
export (Texture) var iron
export (Texture) var rock
export (Texture) var pink
export (Texture) var green
export (Texture) var red
export (Texture) var blue
export (Texture) var lock
export (Texture) var moss
export (Texture) var ice



func set_goal(new_goal_type, new_max):
	goal_type = new_goal_type
	match goal_type:
		"CINNABARIT":
			texture_rect.texture = cinnabarit
		"COAL":
			texture_rect.texture = coal
		"QUARTZ":
			texture_rect.texture = quartz
		"SPHALERITE":
			texture_rect.texture = sphalerite
		"COPPER":
			texture_rect.texture = copper
		"IRON":
			texture_rect.texture = iron
		"ROCK":
			texture_rect.texture = rock
		"PINK":
			texture_rect.texture = pink
		"GREEN":
			texture_rect.texture = green
		"RED":
			texture_rect.texture = red
		"BLUE":
			texture_rect.texture = blue
		"LOCK" :
			texture_rect.texture = lock
		"MOSS" :
			texture_rect.texture = moss
		"ICE" :
			texture_rect.texture = ice
		_:
			texture_rect.texture = null
	max_value = new_max
	goal_label.text = "" + String(current_value) + " / " + String(max_value) + ""


func update_goal(new_goal_type):
	if goal_type == new_goal_type:
		current_value += 1
		if current_value == max_value:
			goal_label.text = "" + String(current_value) + " / " + String(max_value) + ""
			is_goal_met = true
			return true
		else:
			goal_label.text = "" + String(current_value) + " / " + String(max_value) + ""
			return false




