extends Button


func _process(_delta):
	if get_tree().paused == true:
		hide()
	else:
		show()
