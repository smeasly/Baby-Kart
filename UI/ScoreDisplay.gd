#keep and display score

extends Label; "res://Main.gd"


func _ready():
	text = "Score: 0"


func _on_Main_update_score(score: int):
	text = "Score: %s" % score
