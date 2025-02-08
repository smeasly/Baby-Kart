extends KinematicBody2D


var MAX_SPEED : int = 500; var MAX_BACKSPEED : int = 250
var ACCEL : int = 1000; var DECEL : int = 750

var direction : float
var leftAccel : float; var rightAccel : float
var speed : float = 0; var backSpeed : float = 0 #not *actual* speed, it's a scaling multiplier for velocity
var velocity = Vector2.ZERO

var maxAngularAccel : float = 5

var angularAccelCoef : float = 0.6
var angularDecelCoef : float = 0.35

const GREEN_CAR = preload("res://player/car.png")
const BLUE_CAR = preload("res://player/car2.png")
const RED_CAR = preload("res://player/car3.png")
#const PURPLE_CAR = preload("res://player/car4.png") #Was supposed to impart more bounce to ball, but i can't seem to make a Kinematic body work like that.
var carTypes : Array = [GREEN_CAR, BLUE_CAR, RED_CAR]

var called: bool = false
var shape: CollisionShape2D #empty collsion shape

export var crashParticle : PackedScene
var _particle : Object


func _ready():
	rotation_degrees = 90


#CHOOSE CAR COLOR AND STATS
func _on_MainMenu_change_player_sprite(value):
	$Sprite.texture = carTypes[value]
	set_stats_from_cartype(value)

func set_stats_from_cartype(value : int):
	
	match value:
		0: #GREEN_CAR, default balanced
			maxAngularAccel = 5.5
			angularAccelCoef = 0.65
			angularDecelCoef = 0.35
			MAX_SPEED = 515
			MAX_BACKSPEED = 275
			ACCEL = 1000
			DECEL = 750
			return
		
		1: #BLUE_CAR, better turning, worse speed
			maxAngularAccel = 7
			angularAccelCoef = 0.9
			angularDecelCoef = 0.45
			MAX_SPEED = 475
			MAX_BACKSPEED = 200
			ACCEL = 925
			DECEL = 800
			return
		
		2: #RED_CAR, better speed, worse turning
			maxAngularAccel = 5.5
			angularAccelCoef = 0.5
			angularDecelCoef = 0.3
			MAX_SPEED = 650
			MAX_BACKSPEED = 375
			ACCEL = 1250
			DECEL = 650
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
	
	leftAccel = clamp(leftAccel, 0, maxAngularAccel)
	rightAccel = clamp(rightAccel, 0, maxAngularAccel)
	
	if inputLeft: #&& (speed > 125 || backSpeed > 200):
		leftAccel += angularAccelCoef
		direction -= leftAccel * delta
		
	elif !inputLeft: #and leftAccel != 0:
		leftAccel -= angularDecelCoef
		direction -= leftAccel * delta
	
	if inputRight: #&& (speed > 125 || backSpeed > 200):
		rightAccel += angularAccelCoef
		direction += rightAccel * delta
		
	elif !inputRight: #and rightAccel != 0:
		rightAccel -= angularDecelCoef
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


func collision(delta):
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


func _physics_process(delta):
	
	#INPUT
	manual_input(delta)
	rotation += direction
	velocity = move_and_slide(velocity, Vector2(), false, 4, PI/4, true) #this last bool controls whether or not this object has infinite inertia.
	
	#PARTICLE TRAIL & CAR MOVEMENT SOUNDS
	if speed > 125: #|| backSpeed > 200:
		$ParticleTrail.emitting = true
		#$AudioStreamPlayer.queuePlay = true
		if $ParticleTrail.visible == false:
			$ParticleTrail.show()
		
	elif speed <= 125 && $ParticleTrail.is_emitting() == true:
		$ParticleTrail.emitting = false
		#$AudioStreamPlayer.queuePlay = false
	
	if speed >= 125:
		$AudioStreamPlayer.queuePlay = true
		
	elif speed <= 175:
		$AudioStreamPlayer.queuePlay = false
		
	elif speed <= 15:
		$AudioStreamPlayer.stop()
	
	#COLLISION
	collision(delta)


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
