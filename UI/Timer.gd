extends Timer


func _ready():
	start(60)
	$TimerDisplay.text = "Time: %s" % time_left


func _physics_process(_delta):
	$TimerDisplay.text = "Time: %s" % stepify(time_left, 00.1)
	
	if time_left <= 0.1:
		$TimerDisplay.text = "Time's Up!"


func _on_HourglassPickup_pickup():
	start(time_left + 5) #add 5 seconds to time limit


func _on_Main_reset():
	start(60)
	$TimerDisplay.text = "Time: %s" % time_left
