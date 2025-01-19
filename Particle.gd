#basic self-free script for all particles

extends Particles2D


onready var timeCreated = Time.get_ticks_msec()


func _process(_delta):
	if Time.get_ticks_msec() - timeCreated > 5000:
		queue_free()
