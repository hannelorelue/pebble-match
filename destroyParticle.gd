extends Particles2D



# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
