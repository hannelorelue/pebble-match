extends Node

onready var path =  "user://savegame.save"
#var level_info = {}
var level_info = {
	1:{
		"unlocked" : true,
		"high_score" : 0,
		"stars_unlocked" : 0,
		"empty_spaces" : [
			Vector2(0,0),
			Vector2(0,1),
			Vector2(0,2),
			Vector2(0,3),
			Vector2(0,4),
			Vector2(0,5),
			Vector2(0,6),
			Vector2(0,7),
			Vector2(7,0),
			Vector2(7,1),
			Vector2(7,2),
			Vector2(7,3),
			Vector2(7,4),
			Vector2(7,5),
			Vector2(7,6),
			Vector2(7,7),
			Vector2(1,0),
			Vector2(2,0),
			Vector2(3,0),
			Vector2(4,0),
			Vector2(5,0),
			Vector2(6,0),
			Vector2(1,7),
			Vector2(2,7),
			Vector2(3,7),
			Vector2(4,7),
			Vector2(5,7),
			Vector2(6,7),
		],
		"concrete_spaces" :[Vector2(2,3)],
		"ice_spaces" :[Vector2(2,5), Vector2(2,4)],
		"lock_spaces" : [Vector2(4,3)],
		"slime_spaces" : [Vector2(2,3)],
		"piece_value" : 20,
		"max_score" : 500,
		"counter_value" : 13,
		"is_move" : true,
	},
	
	2:{
		"unlocked" : false,
		"high_score" : 0,
		"stars_unlocked" : 0,
		"concrete_spaces" :[Vector2(2,3)],
		"empty_spaces" : [Vector2(1,3)],
		"ice_spaces" :[Vector2(2,5)],
		"lock_spaces" : [Vector2(4,3)],
		"slime_spaces" : [Vector2(2,3)],
		"piece_value" : 20,
		"max_score" : 500,
		"counter_value" : 13,
		"is_move" : true,
	},
}


# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()


func save_data():
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err != OK:
		print ("something went wrong at saving")
		return
	file.store_var(level_info)
	file.close()


func load_data():
	var file = File.new()
	var err = file.open(path, File.READ)
	if err != OK:
		print ("something went wrong at loading")
		return
	var read = {}
	read = file.get_var()
	return read
