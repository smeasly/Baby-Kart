extends Timer

#start paused
#set start time to 30sec
#emit signal on timeout

signal timer_time_remaining

func _ready():
	start(60)


func _physics_process(_delta):
	emit_signal("timer_time_remaining",  stepify(time_left, 00.1))
#	if is_stopped():
#		set_process(!is_processing())


func _on_HourglassPickup_pickup():
	#add ~5 seconds to time limit
	start(time_left + 5)
	if time_left > 60:
		start(60)


func _on_Main_reset():
	start(60)
