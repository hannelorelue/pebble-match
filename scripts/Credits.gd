extends CanvasLayer

signal back_Button_pressed

func slide_in():
	$AnimationPlayer.play("slide_in")


func slide_out():
	$AnimationPlayer.play_backwards("slide_in")

func _on_Button_pressed():
	OS.shell_open("https://honeycodes.dev/")


func _on_LinkButton_pressed():
	OS.shell_open("http://godotengine.org")


func _on_BackButton_pressed():
	emit_signal("back_Button_pressed")


func _on_Aseprite_pressed():
	OS.shell_open("https://www.aseprite.org/")


func _on_Abstraction_pressed():
	OS.shell_open("http://www.abstractionmusic.com/")


func _on_szadiart_pressed():
	OS.shell_open("https://szadiart.itch.io/")

