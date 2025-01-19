#get random position pickup/ball spawn and detect if not blocked, otherwise move and test again

extends Area2D


signal newPosition


onready var PlayerCar = get_node("/root/Main/PlayerCar")
onready var Ball = get_node("/root/Main/Ball")
#export var ball : PackedScene
#export var pickup : PackedScene

var safePosition: Vector2
var possiblePosition: Vector2

func get_possible_position():
	
	var screenSize: Vector2 = get_viewport_rect().size
	
	possiblePosition.x = rand_range(64, screenSize.x - 230)
	possiblePosition.y = rand_range(64, screenSize.y - 64)
	
	return possiblePosition


func get_safe_position(): 
	
	position = get_possible_position()
	
	#for body in SpawnCheck.get_overlapping_bodies():
	#	if body.is_type(PhysicsBody2D):
	#		get_possible_position
	#	else:
	#		safePosition = position
	#		return safePosition
	
	if overlaps_body(PlayerCar):
		get_possible_position()
	else:
		safePosition = position
		return safePosition


func _on_Main_get_new_position():
	
	get_safe_position()
	
	emit_signal("newPosition", safePosition)
	
	position = Vector2(0,0)
	safePosition = Vector2(0,0)
	possiblePosition = Vector2(0,0)
