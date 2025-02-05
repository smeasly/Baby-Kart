extends KinematicBody2D


const MAX_SPEED : int = 500; const MAX_BACKSPEED : int = 250
const ACCEL : int = 1000; const DECEL : int = 750

var direction : float
var leftAccel : float; var rightAccel : float
var speed : float = 0; var backSpeed : float = 0 #not *actual* speed, it's a scaling multiplier for velocity
var velocity = Vector2.ZERO

var maxAngularAccel : float = 6

const GREEN_CAR = preload("res://player/car.png")
const BLUE_CAR = preload("res://player/car2.png")
const RED_CAR = preload("res://player/car3.png")
var carTypes = [GREEN_CAR, BLUE_CAR, RED_CAR]
var currentType = 0

var called: bool = false
var shape: CollisionShape2D #empty collsion shape

export var crashParticle : PackedScene #TODO make new particles specific for crash, currently using despawn particles
var _particle : Object


func _ready():
	rotation_degrees = 90


func _on_MainMenu_change_player_sprite(value):
	$Sprite.texture = carTypes[value]
	currentType = value

func set_stats_from_cartype(): #currently unused behaviour
	
	match currentType:
		0: #GREEN_CAR, default balanced
			#maxAngularAccel = 5
			#AngularAccelCoef = 0.7
			#AngularDecelCoef = 0.35
			#MAX_SPEED = 500
			#MAX_BACKSPEED = 250
			#ACCEL = 1000
			#DECEL = 750
			print("set type ", currentType)
			return
		
		1: #BLUE_CAR, better handling
			#maxAngularAccel = 6.5
			#AngularAccelCoef = 0.9
			#AngularDecelCoef = 0.45
			#MAX_SPEED = 450
			#MAX_BACKSPEED = 200
			#ACCEL = 925
			#DECEL = 800
			print("set type ", currentType)
			return
		
		2: #RED_CAR, better speed
			#maxAngularAccel = 4
			#AngularAccelCoef = 0.5
			#AngularDecelCoef = 0.3
			#MAX_SPEED = 750
			#MAX_BACKSPEED = 300
			#ACCEL = 1250
			#DECEL = 650
			print("set type ", currentType)
			return


func manual_input(delta):
	
	var inputUp = Input.is_action_pressed("ui_up")
	var inputDown = Input.is_action_pressed("ui_down")
	var inputLeft = Input.is_action_pressed("ui_left")
	var inputRight = Input.is_action_pressed("ui_right")
	
	velocity = Vector2.ZERO
	direction = 0
	
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
	
	leftAccel = clamp(leftAccel, 0, 5)
	rightAccel = clamp(rightAccel, 0, 5)
	
	if inputLeft: #&& (speed > 125 || backSpeed > 200):
		leftAccel += 0.6
		direction -= leftAccel * delta
		
	elif !inputLeft: #and leftAccel != 0:
		leftAccel -= 0.35
		direction -= leftAccel * delta
	
	if inputRight: #&& (speed > 125 || backSpeed > 200):
		rightAccel += 0.6
		direction += rightAccel * delta
		
	elif !inputRight: #and rightAccel != 0:
		rightAccel -= 0.35
		direction += rightAccel * delta
	
	#if inputLeft && (!inputDown || !inputUp):
	#	leftAccel -= 0.35
	#	direction -= leftAccel * delta
	
	#if inputRight && (!inputDown || !inputUp)
	#	rightAccel -= 0.35
	#	direction += rightAccel * delta
	
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


#func collision(delta):
#
##COLLISION HANDLING & COLLISION SOUNDS + COLLISION PARTICLES
#	if called == true: #set flag for collision sound
#		var vx = abs(velocity.x)
#		var vy = abs(velocity.y)
#		if vx + vy > 420: #check: print(velocity.x, ":", velocity.y)
#			called = false
#
#	for index in get_slide_count(): #for each collision event, called every frame of detected collision...
#
#		var collision = get_slide_collision(index) 
#
#		if collision.collider.is_class("StaticBody2D"): #slow down upon hitting an obstacle
#			speed -= (ACCEL * 2) * delta
#			backSpeed -= (ACCEL * 2) * delta
#
#		if index > 0: #get_slide_collision(0) is called every frame, not exactly sure why, but doing n > 0 will at least lower compute cost
#
#			if called == false: 
#
#				if speed > 375:
#					_particle = crashParticle.instance()
#					_particle.position = collision.position
#					play_particle()
#					AudioStreamSfxManager.play("res://sfx/wall_bump.wav", true, 1.3, 0.7, 1.2)
#
#				else:
#					AudioStreamSfxManager.play("res://sfx/wall_bump.wav", true, 0.0, 1.0, 1.5)
#
#				shape = collision.collider_shape   #log set first collision with a shape
#				called = true
#
#			#need to log last TWO shapes, to avoid issues of overcalling in corners/intersection of 2 shapes
#			if collision.collider_shape != shape: #can comment this out for potentially more stable behaviour, but for now it works just fine
#				called = false


func _physics_process(delta):
	
	#INPUT
	manual_input(delta)
	rotation += direction
	velocity = move_and_slide(velocity, Vector2(), false, 4, PI/4, true) #this last bool controls whether or not this object has infinite inertia.
	
	#PARTICLE TRAIL & CAR MOVEMENT SOUNDS
	if speed > 125: #|| backSpeed > 200:
		$ParticleTrail.emitting = true
		#$AudioStreamPlayer.queuePlay = true
		
	elif speed <= 125 && $ParticleTrail.is_emitting() == true:
		$ParticleTrail.emitting = false
		#$AudioStreamPlayer.queuePlay = false
	
	if speed >= 125:
		$AudioStreamPlayer.queuePlay = true
		
	elif speed <= 175:
		$AudioStreamPlayer.queuePlay = false
		
	elif speed <= 15:
		$AudioStreamPlayer.stop()

	
	#COLLISION HANDLING & COLLISION SOUNDS + COLLISION PARTICLES
	#collision(delta)
	if called == true: #set flag for collision sound
		var vx = abs(velocity.x)
		var vy = abs(velocity.y)
		
		if vx + vy > 420: #check: print(vx, ":", vy)
			called = false
	
	for index in get_slide_count(): #for each collision event, called every frame of detected collision...
		
		var collision = get_slide_collision(index) 
		
		if collision.collider.is_class("StaticBody2D"): #slow down upon hitting an obstacle
			speed -= (ACCEL * 2) * delta
			backSpeed -= (ACCEL * 2) * delta
		
		if index > 0: #get_slide_collision(0) is called every frame, not exactly sure why, but doing n > 0 will at least lower compute cost
			
			if called == false: 
				
				if speed > 375:
					_particle = crashParticle.instance()
					_particle.position = collision.position
					play_particle()
					AudioStreamSfxManager.play("res://sfx/wall_bump.wav", true, 1.3, 0.7, 1.2)
					
				else:
					AudioStreamSfxManager.play("res://sfx/wall_bump.wav", true, 0.0, 1.0, 1.5)
				
				shape = collision.collider_shape   #log set first collision with a shape
				called = true
			
			#need to log last TWO shapes, to avoid issues of overcalling in corners/intersection of 2 shapes
			if collision.collider_shape != shape: #can comment this out for potentially more stable behaviour, but for now it works just fine
				called = false
		
		#this following part of the block is my attempt at fixing the 'stop on collide' issue, caused when property
		#infinite_inertia = false. it didn't work and is therefore commented out, but i may be able to get it to work later
		#this implementation required putting ' export(float, 0, 1) var pushFactor ' at the head of the script
	#		clamp(pushFactor, 0, 1)
	#		
	#		if speed > 0:
	#			pushFactor = speed / MAX_SPEED
	#		elif backSpeed > 0:
	#			pushFactor = backSpeed / MAX_BACKSPEED
	#		
	#		collision.collider.apply_central_impulse(-collision.normal * velocity.length() * pushFactor)


func play_particle():
	
	_particle.emitting = true
	#_particle.color = color(0,1,1,1)
	
	get_tree().current_scene.call_deferred("add_child", _particle)


func _on_Main_reset():
	
	velocity = Vector2.ZERO
	leftAccel = 0
	rightAccel = 0
	speed = 0
	direction = 0
	position = Vector2(141, 283)
	rotation_degrees = 90
