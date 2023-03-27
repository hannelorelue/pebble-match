extends Node2D

export (int)  var health


func take_damage(damage):
	health  -= damage
	modulate.a = health * 0.3
