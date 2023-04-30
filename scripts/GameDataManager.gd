extends Node

onready var path =  "user://savegame.save"
#var level_info = {}
var level_info = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()


func save_data():
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err != OK:
		print ("something went wrong at saving")
		return
	var dict = {}
	for level in level_info:
		dict[level] = {
			"unlocked" : level_info[level]["unlocked"],
			"high_score" : level_info[level]["high_score"],
			"date" : level_info[level]["date"],
			"stars_unlocked" : level_info[level]["stars_unlocked"],
		}
	file.store_var(dict)
	file.close()


func load_data():
	var levels = ResourceLoader.load("res://scripts/Levels.gd").new()
	level_info = levels.get_levels()
	var file = File.new()
	if not file.file_exists(path):
		for level in level_info:
			level_info[level]["unlocked"] = false
			level_info[level]["high_score"] = 0
			level_info[level]["date"] = ""
			level_info[level]["stars_unlocked"]  = 0
		level_info[1]["unlocked"] = true
	var err = file.open(path, File.READ)
	if err != OK:
		print ("something went wrong at loading")
		return
	var read = {}
	read = file.get_var()
	for level in read:
		level_info[level]["unlocked"] = read[level]["unlocked"]
		level_info[level]["high_score"] = read[level]["high_score"]
		level_info[level]["date"] = read[level]["date"]
		level_info[level]["stars_unlocked"]  = read[level]["stars_unlocked"]



func clear_data():
	var dir = Directory.new()
	dir.remove(path)
	get_tree().quit()
