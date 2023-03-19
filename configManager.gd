extends Node

onready var path = "/Users/hanni/Programming/godot/candy-crush/config.cfg"
var sound_on 
var music_on 


# Called when the node enters the scene tree for the first time.
func _ready():
	load_config()


func save_config():
	var config = ConfigFile.new()
	config.set_value("audio", "sound", sound_on)
	config.set_value("audio", "music", music_on)
	var err = config.save(path)
	if err != OK:
		print ("something went wrong")


func load_config() :
	var config = ConfigFile.new()
	var default_options = {
			"sound": true,
			"music": true,
	}
	var err = config.load(path)
	if err != OK:
		return default_options
	#var options = {}
	sound_on = config.get_value("audio", "sound", default_options.sound )
	music_on = config.get_value("audio", "music", default_options.music )
