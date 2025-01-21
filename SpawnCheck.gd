#get random position pickup/ball spawn and detect if not blocked, otherwise move and test again
#not exactly working properly. need to heavily change this. maybe use AABB?
#also, the way pickup spawning is currently implemented, this code does not take into account the pickup spawning so overlapping
#may still occur. there's a hacky solution on the Main script. an easier solution might be to do away with this check script
#and divide the screen into quadrants, and have each consecutive spawn happen in a different quadrant. that still leaves the issue
#of overlapping with the car. could maybe check which quad the car is in and spawn in a different quad? would probably require a separate
#script anyway, and have problems that are similar to this current iteration which i would have to solve anyway.

extends Area2D


signal newPosition


onready var PlayerCar = get_node("/root/Main/PlayerCar")
#export var ball : PackedScene
#export var pickup : PackedScene

var safePosition: Vector2
var possiblePosition: Vector2


func get_possible_position() -> Vector2:
	
	var screenSize: Vector2 = get_viewport_rect().size
	
	possiblePosition.x = rand_range(128, screenSize.x - 230)
	possiblePosition.y = rand_range(128, screenSize.y - 128)
	
	return possiblePosition


func get_safe_position():
	
	position = get_possible_position()
	
	#for body in get_overlapping_bodies():
	#	if body.is_class("PhysicsBody2D"):
	#		position = get_possible_position()
	#		
	#	else:
	#		safePosition = position
	#		return safePosition
	
	if overlaps_body(PlayerCar):	#Note: The result of this test is not immediate after moving objects. For performance,
		get_possible_position()		#list of overlaps is updated once per frame and before the physics step. Consider using signals instead.
		#position = get_possible_position() causes undesired behaviour. need to look at this.
	else:
		safePosition = position
		return safePosition


func _on_Main_get_new_position():
	
	get_safe_position()
	
	emit_signal("newPosition", safePosition)
	
	#position = Vector2(0,0)
	#safePosition = Vector2(0,0)
	#possiblePosition = Vector2(0,0)
