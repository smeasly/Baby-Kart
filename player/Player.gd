#Player car control script

extends KinematicBody2D


const MAX_SPEED : int = 500; const MAX_BACKSPEED : int = 250
const ACCEL : int = 1000; const DECEL : int = 750

var direction : float
var leftAccel : float; var rightAccel : float
var angularAccel : float = 6
var speed : float = 0; var backSpeed : float = 0 #not *actual* speed
var velocity = Vector2.ZERO


func _ready():
	
	rotation_degrees = 90


func manual_input(delta):
	
	var inputUp = Input.is_action_pressed("ui_up") #i can do this in input mapping in project settings, but this is fine for now
	var inputDown = Input.is_action_pressed("ui_down")
	var inputLeft = Input.is_action_pressed("ui_left")
	var inputRight = Input.is_action_pressed("ui_right")
	
	velocity = Vector2.ZERO
	direction = 0
	leftAccel = clamp(leftAccel, 0, 4.5) #do we need to clamp this every frame? probably not. move this to head declare block
	rightAccel = clamp(rightAccel, 0, 4.5)
	
	
	#STEERING
	
	#TODO use range_lerp() to make steering slower at high speeds
	#var variable
	#var 1valueMin:float; var 1valueMax:int
	#var 2valueMin:int; var valueMax2:float
	#var output
	#output = range_lerp(variable, 1valueMin, 1valueMax, 2valueMin, 2valueMax)
	
	#● float range_lerp(value: float, istart: float, istop: float, ostart: float, ostop: float)
	#Maps a value from range [istart, istop] to [ostart, ostop]. See also lerp() and inverse_lerp(). 
	#If value is outside [istart, istop], then the resulting value will also be outside [ostart, ostop]. 
	#Use clamp() on the result of range_lerp() if this is not desired.
	#range_lerp(75, 0, 100, -1, 1) # Returns 0.5
	
	
	#leftAccelAdd = range_lerp(speed, 1, MAX_SPEED, 0.8, 0.2)	something like this?; as speed approaches max, 
	#leftAccelAdd = clamp(leftAccelAdd, 0.2, 0.8)				turnAccelAdd approaches min.
	#if inputLeft:
	#	leftAccel += leftAccelAdd
	
	
	if inputLeft: #and (speed > 0 or backSpeed > 0):
		leftAccel += 0.7
		direction -= leftAccel * delta
	elif !inputLeft and leftAccel != 0:
		leftAccel -= 0.35
		direction -= leftAccel * delta
	
	if inputRight: #and (speed > 0 or backSpeed > 0):
		rightAccel += 0.7
		direction += rightAccel * delta
	elif !inputRight and rightAccel != 0:
		rightAccel -= 0.35
		direction += rightAccel * delta
	
	#ACCELERATION AND DECELERATION
	speed = clamp(speed, 0, MAX_SPEED)
	backSpeed = clamp(backSpeed, 0, MAX_BACKSPEED)
	
	if inputUp:
		speed += ACCEL * delta
		velocity += Vector2.UP.rotated(rotation) * speed
	elif !inputUp && speed > 0:
		speed -= DECEL * delta
		velocity += Vector2.UP.rotated(rotation) * speed
	
	if inputDown:
		backSpeed += ACCEL * delta
		velocity += Vector2.DOWN.rotated(rotation) * backSpeed
	elif !inputDown && backSpeed > 0:
		backSpeed -= DECEL * delta
		velocity += Vector2.DOWN.rotated(rotation) * backSpeed

func _physics_process(delta):
	
	manual_input(delta)
	rotation += direction
	velocity = move_and_slide(velocity, Vector2(), false, 4, PI/4, true)
	#this last bool-var controls whether or not this object has infinite inertia. The "correct" way to do this
	#would to have this var set to false and 
	
	for index in get_slide_count(): #maybe use physics2ddirectspacestate collide_shape() here?
		
		var collision = get_slide_collision(index)
		#var last = get_last_slide_collision()
		
		if collision.collider.is_class("StaticBody2D"):
			speed -= ACCEL * delta
		
		#this following part of the block is my attempt at fixing the 'stop on collide' issue, caused when property
		#infinite inertia is turned off. it didn't work and is therefore commented out, but i may be able to get it to work later
		#this implementation required putting ' export(float, 0, 1) var pushFactor ' at the head of the script
		
	#	if collision.collider.is_class("RigidBody2D"): 
	#		clamp(pushFactor, 0, 1)
	#		
	#		if speed > 0:
	#			pushFactor = speed / MAX_SPEED
	#		elif backSpeed > 0:
	#			pushFactor = backSpeed / MAX_BACKSPEED
	#		
	#		collision.collider.apply_central_impulse(-collision.normal * velocity.length() * pushFactor)


#func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_RIGHT and event.pressed:
#			#need to turn off trails temporarily here
#			position = get_viewport().get_mouse_position()
#			#not sure how to implement 'dropping' effect here. maybe create separate function for tweening car to new location
#			#and then do some resizing process in this block. might need _process()?
#			if $Sprite.scale(Vector2(3, 3)):
#			$Sprite.scale(1, 1) * delta
#			resize($Car.png)


func _on_Play_pressed():
	show()


func _on_Main_reset():
	velocity = Vector2.ZERO
	leftAccel = 0
	rightAccel = 0
	speed = 0
	direction = 0
	position = Vector2(141, 283)
	rotation_degrees = 90
