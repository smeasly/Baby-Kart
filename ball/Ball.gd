extends RigidBody2D 


var queueReset: bool = false
var screenSize: Vector2 = Vector2()
var randomPos: Vector2 = Vector2()


func _ready():
	#Connect score signal to each new instance of Ball on instance
	
	var NetDetectArea2D = get_node("/root/Main/Net/NetDetectArea2D")
	var Main = get_node("/root/Main")
	
	NetDetectArea2D.connect("score",self,"_on_NetDetectArea2D_score") 
	Main.connect("reset",self,"_on_Main_reset")


func set_random_position():
	screenSize = get_viewport_rect().size
	randomPos.x = rand_range(64, screenSize.x - 230)
	randomPos.y = rand_range(64, screenSize.y - 64)
	position = Vector2(randomPos.x, randomPos.y)


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if queueReset:
		
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		
		queueReset = false
		return


func _on_VisibilityNotifier2D_screen_exited(): # this is a work around/failsafe for the ball tunneling through the wall
	set_random_position()
	queueReset = true


func _on_NetDetectArea2D_score():
	#TODO play particles
	queue_free()


func _on_Main_reset():
	set_random_position()
	queueReset = true


func _on_Play_pressed():
	show()
