extends Node2D

const PieceType = {
	COAL = "coal",
	CINNABARIT = "cinnabarit",
	COPPER = "copper",
	ROCK = "rock",
	IRON = "iron",
	QUARTZ = "quartz",
	SPHALERITE = "sphalerite",
}

export (int) var height = 8
export (int) var width = 8
export (int) var offset = 64
export (int) var x_start = 64
export (int) var y_start = 800

var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func goto_level(level):
	call_deferred("_deferred_goto_level", level)

func _deferred_goto_scene(path):
	if is_instance_valid(current_scene):
		current_scene.free()

	var s = ResourceLoader.load(path)

	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	

func _deferred_goto_level(level):
	var path = "res://scenes/game_window.tscn"
	if is_instance_valid(current_scene):
		current_scene.free()

	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	var level_info = GameDataManager.level_info[level]
	current_scene.set_level_info(level, level_info["empty_spaces"], level_info["concrete_spaces"], 
		level_info["ice_spaces"], level_info["lock_spaces"], level_info["slime_spaces"], 
		level_info["max_score"],  level_info["counter_value"], level_info["is_move"],  level_info["piece_value"], 
		level_info["is_sinker_in_scene"], level_info["max_sinkers"], level_info["No_piece_types"], level_info["goals"] )
	get_tree().get_root().add_child(current_scene)

	get_tree().set_current_scene(current_scene)
	

