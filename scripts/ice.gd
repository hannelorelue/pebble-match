extends Node2D

export (int) var health = 4


func take_damage(damage):
	health  -= damage
	#modulate.a = health * 0.3
