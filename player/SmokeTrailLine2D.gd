extends Line2D

var length = 35
var point = Vector2()
#var offsetRight = Vector2(-14, 32)
#var offsetLeft = Vector2(14, 32)

func _process(_delta):
	global_position = Vector2(0, 0)
	global_rotation = 0
	point = get_parent().global_position
	add_point(point)
	while get_point_count() > length:
		remove_point(0)
