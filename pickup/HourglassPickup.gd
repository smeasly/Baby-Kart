extends Area2D


signal pickup


func _ready():
	#Connect reset and pickup signals on each new instance
	#TODO play particles and sounds
	var Timer = get_node("/root/Main/Timer")
	var Main = get_node("/root/Main")
	
	self.connect("pickup",Timer,"_on_HourglassPickup_pickup")
	
	Main.connect("reset",self,"_on_Main_reset")
	self.connect("pickup",Main,"_on_HourglassPickup_pickup")


func _on_HourglassPickup_body_entered(body):
	if body.is_class("KinematicBody2D"):
		emit_signal("pickup") 
		queue_free()
		#TODO play particles and sounds


func _on_Main_reset():
	queue_free()
