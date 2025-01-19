extends Label

var timeLeft:float


func _ready():
	text = "Time: %s" % timeLeft


func _on_Timer_timer_time_remaining(time_left):
	timeLeft = time_left
	text = "Time: %s" % time_left #can i make the text red at < 5 seconds?
#	if time_left <= 0:
#		text = "Timeout!"
