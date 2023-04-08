extends "res://scripts/menu.gd"

onready var label = $MarginContainer/TextureRect/VBoxContainer/Label

func _on_ContinueButton_pressed():
	Global.goto_scene("res://scenes/GameMenu.tscn")


func _on_grid_game_won(score):
	label.text = String(score)
	slide_in()

