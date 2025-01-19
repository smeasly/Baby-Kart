extends Control



func _ready():
	show()


func _onpause():
#	if get_tree().paused && queueMenu == true:
#		show()
#	else:
#		hide()
	pass


func _on_Play_pressed():
	hide()
	#TODO change menu configuration from onstart menu to pause/resume menu. ie: change play to resume, add try again button.
