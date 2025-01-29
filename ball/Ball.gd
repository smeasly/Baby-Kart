extends RigidBody2D 


export var spawnParticle : PackedScene
export var despawnParticle : PackedScene
var _particle : Object

var queueReset: bool = false
var screenSize: Vector2 = Vector2()
var randomPos: Vector2 = Vector2()
var spriteStartRotation : float


func _ready(): #Connect score signal to each new instance of Ball on instance
	
	spriteStartRotation = global_rotation_degrees
	
	var NetDetectArea2D = get_node("/root/Main/Net/NetDetectArea2D")
	var Main = get_node("/root/Main")
	
	NetDetectArea2D.connect("score",self,"_on_NetDetectArea2D_score") 
	Main.connect("reset",self,"_on_Main_reset")
	
	_particle = spawnParticle.instance()
	play_particle()


func set_random_position():
	
	screenSize = get_viewport_rect().size
	randomPos.x = rand_range(64, screenSize.x - 230)
	randomPos.y = rand_range(64, screenSize.y - 64)
	position = Vector2(randomPos.x, randomPos.y)


func _integrate_forces(state: Physics2DDirectBodyState):
	
	if queueReset:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		
		_particle = despawnParticle.instance()
		play_particle()
		
		$Line2D.show()
		
		queueReset = false
		return


func _process(_delta):
	
	$Sprite.set_global_rotation_degrees(spriteStartRotation)


func play_particle():
	
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	#_particle.color = color(0,1,1,1)
	
	get_tree().current_scene.call_deferred("add_child", _particle)


func _on_VisibilityNotifier2D_screen_exited(): # this is a work around/failsafe for the ball tunneling through the wall
	
	$Line2D.hide()
	
	set_random_position()
	queueReset = true


func _on_NetDetectArea2D_score():
	
	_particle = despawnParticle.instance()
	play_particle()
	
	queue_free()


func _on_Main_reset():
	
	$Line2D.hide()
	
	#set_random_position()
	#queueReset = true
