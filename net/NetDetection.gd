extends Area2D #detect ball in net and report score


signal score


func _on_NetDetectArea2D_body_entered(body): 	#this is a self-connected signal, which i believe is bad form.
	if body.is_class("RigidBody2D"):			#nevertheless this is how i got it to work.
		emit_signal("score")
