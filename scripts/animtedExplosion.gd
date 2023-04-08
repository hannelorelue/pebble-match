extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2.play()
	pass # Replace with function body.



func _on_AnimatedSprite_animation_finished():
	queue_free()



func _on_AnimatedSprite2_animation_finished():
	queue_free()
	pass # Replace with function body.
