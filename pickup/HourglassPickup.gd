extends Area2D


signal pickup

export var spawnParticle : PackedScene
export var despawnParticle : PackedScene

var _particle : Object


func _ready():
	
	#Connects reset and pickup(score and add time) signals on each new instance
	var Timer = get_node("/root/Main/Timer")
	var Main = get_node("/root/Main")
	
	self.connect("pickup",Timer,"_on_HourglassPickup_pickup")
	
	Main.connect("reset",self,"_on_Main_reset")
	self.connect("pickup",Main,"_on_HourglassPickup_pickup")
	
	_particle = spawnParticle.instance()
	play_particle()


func play_particle():
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.call_deferred("add_child", _particle)


func _on_HourglassPickup_body_entered(body):
	if body.is_class("KinematicBody2D"):
		emit_signal("pickup") 
		
		_particle = despawnParticle.instance()
		play_particle()
		
		queue_free()


func _on_Main_reset():
	if is_instance_valid(_particle):
		_particle.queue_free()
	queue_free()
