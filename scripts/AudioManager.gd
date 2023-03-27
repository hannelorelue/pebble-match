extends Node

onready var music_player = $MusicPlayer
onready var sound_player = $SoundPlayer

var music_list = [
	preload("res://art/Match 3 Sounds/Music/theme-1.ogg"), 
	preload("res://art/Match 3 Sounds/Music/theme-2.ogg"), 
	preload("res://art/Match 3 Sounds/Music/theme-3.ogg"), 
	preload("res://art/Match 3 Sounds/Music/theme-4.ogg"),
]


var sound_list = [
	preload("res://art/Match 3 Sounds/Sounds/1.ogg"), 
	preload("res://art/Match 3 Sounds/Sounds/3.ogg"), 
	preload("res://art/Match 3 Sounds/Sounds/4.ogg"), 
	preload("res://art/Match 3 Sounds/Sounds/5.ogg"), 
	preload("res://art/Match 3 Sounds/Sounds/6.ogg"), 
	preload("res://art/Match 3 Sounds/Sounds/7.ogg"),
]


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_volume()
	play_random_music()


func play_random_music():
	var temp = floor(rand_range(0, music_list.size()))
	music_player.stream = music_list[temp]
	music_player.play()


func play_random_sound():
	var temp = floor(rand_range(0, sound_list.size()))
	sound_player.stream = sound_list[temp]
	sound_player.play()
	

func play_fixed_sound(sound):
	sound_player.stream = sound_list[sound]
	sound_player.play()


func set_volume():
	if ConfigManager.sound_on:
		music_player.set_volume_db(-15.0)
		sound_player.set_volume_db(-15.0)
	else:
		music_player.set_volume_db(-80.0)
		sound_player.set_volume_db(-80.0)


