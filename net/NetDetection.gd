extends Area2D #detect ball in net and report score


signal score


func _on_NetDetectArea2D_body_entered(body):
	if body.is_class("RigidBody2D"):
		emit_signal("score")
