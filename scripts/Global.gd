extends Node2D

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
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func goto_level(level):
	call_deferred("_deferred_goto_level", level)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	

func _deferred_goto_level(level):
	var path = "res://scenes/game_window.tscn"
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()
	var level_info = GameDataManager.level_info[level]
	current_scene.set_level_info(level, level_info["empty_spaces"], level_info["concrete_spaces"], 
		level_info["ice_spaces"], level_info["lock_spaces"], level_info["slime_spaces"], 
		 level_info["max_score"],  level_info["counter_value"],  level_info["is_move"],  level_info["piece_value"], level_info["is_sinker_in_scene"],level_info["max_sinkers"])
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	

