extends Timer


signal timer_time_remaining


func _ready():
	
	start(60)


func _physics_process(_delta):
	
	emit_signal("timer_time_remaining",  stepify(time_left, 00.1))
	
#	if is_stopped():
#		set_process(!is_processing())


func _on_HourglassPickup_pickup():
	
	start(time_left + 5) #add 5 seconds to time limit
	
	if time_left > 60: #don't add above 60 seconds
		start(60)


func _on_Main_reset():
	start(60)
