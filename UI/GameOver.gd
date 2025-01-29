extends Control


#signal try_again


func _on_Main_update_score(score):
	$VBoxContainer/LabelFinalScore.text = "Your Final Score: %s" % score


func _on_TryAgain_pressed():
	pass
	#emit_signal("try_again")
