#keep score, write highscore to file, and handle pausing and opening menus/displaying state

extends Node


class_name Main


export var pickup : PackedScene
export var ball : PackedScene

signal new_high_score
signal get_new_position
signal game_over
signal reset
signal update_score

var score : int = 0
var highScore : int
var queuePickup : bool
var pickupSpawnIncr : int = 0

var newPos  : Vector2
var nextPos : Vector2


func _ready():
	
	get_tree().paused = true


func _on_Play_pressed():
	
	get_tree().paused = false
	
	queuePickup = true
	emit_signal("get_new_position")
	nextPos = newPos  #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn
	
	spawn_ball()


#func _input(event : InputEvent):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_cancel"):
#			var isPaused : bool = get_tree().paused
#			get_tree().paused = !isPaused


func spawn_ball():
	
	var _ball = ball.instance()
	
	emit_signal("get_new_position")
	
	_ball.position = newPos
	call_deferred("add_child", _ball)


func spawn_pickup():
	
	var _pickup = pickup.instance()
	
	#emit_signal("get_new_position")
	
	_pickup.position = nextPos
	call_deferred("add_child", _pickup)
	
	queuePickup = false
	pickupSpawnIncr = 0


func _on_NetDetectArea2D_score():
	
	pickupSpawnIncr += 1
	score += 5
	
	emit_signal("update_score", score)
	
	spawn_ball()
	
	if queuePickup == true && pickupSpawnIncr >= 2:
		spawn_pickup()
	
	if score > highScore: #TODO update highscore file, play sound and anim
		highScore = score
		emit_signal("new_high_score")


func _on_HourglassPickup_pickup():
	
	score += 2
	
	queuePickup = true
	
	emit_signal("update_score", score)
	emit_signal("get_new_position")
	
	pickupSpawnIncr = 0
	nextPos = newPos #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn


func _on_SpawnCheck_newPosition(safePosition):
	
	newPos = safePosition


func _on_Timer_timeout():
	
	emit_signal("game_over")
	get_tree().paused = true


func _on_TryAgain_pressed():
	
	get_tree().paused = false
	
	score = 0
	pickupSpawnIncr = 0
	queuePickup = true
	
	emit_signal("update_score", score)
	emit_signal("reset")


func close_game():
	
	get_tree().quit()


func _on_Quit_pressed():
	
	close_game()


func _on_Exit_pressed():
	
	close_game()
