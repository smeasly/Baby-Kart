extends Line2D

var length = 50
var point = Vector2()

func _process(_delta):
	global_position = Vector2(0, 0)
	global_rotation = 0
	point = get_parent().global_position
	add_point(point)
	while get_point_count() > length:
		remove_point(0)


#func _on_ToggleProcButton_pressed():
#	#!processingFlag
#	set_process(!is_processing())


#func _on_ToggleTrails_pressed():
#	set_visible(!is_visible())
