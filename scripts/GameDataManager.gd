extends Node

onready var path =  "user://savegame.save"
var level_info = {}
var default_level_info = {
	1:{
		"unlocked" : true,
		"high_score" : 0,
		"stars_unlocked" : 0,
		"scene" : "res://scenes/Levels/level1.tscn"
	},
	
	2:{
		"unlocked" : false,
		"high_score" : 0,
		"stars_unlocked" : 0,
		"scene" : "res://scenes/Levels/level2.tscn"
	},
}


# Called when the node enters the scene tree for the first time.
func _ready():
	level_info = load_data()
	if level_info == null:
		level_info = default_level_info



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
