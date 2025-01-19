#keep score, write highscore to file, and handle pausing and opening menus/displaying state

extends Node


class_name Main


var ball = preload("res://ball/Ball.tscn")
var pickup = preload("res://pickup/HourglassPickup.tscn")
#export var pickup : PackedScene
#export var Ball : PackedScene

signal new_high_score
signal get_new_position
signal game_over
signal reset
signal update_score

var score : int = 0
var highScore : int
#var queueBall : bool = false
var queuePickup : bool
var pickupSpawnIncr : int = 0

var newPos  : Vector2
var nextPos : Vector2

#export var gameState: int = GameState.null

#enum GameState {
#	START, 
#	PROCESS, 
#	PAUSED, 
#	FAIL
#}

func _ready():
	get_tree().paused = true

func _on_Play_pressed():
	get_tree().paused = false


#func get_possible_position():
#	#possibleSpawnPos = Vector2(screenSize.x, screenSize.y)
#	var screenSize: Vector2 = get_viewport_rect().size
#	possibleSpawnPos.x = rand_range(30, screenSize.x - 230) #clamp(possibleSpawnPos.x, 0, screenSize.x)
#	possibleSpawnPos.y = rand_range(30, screenSize.y - 30)#clamp(possibleSpawnPos.y, 0, screenSize.y)
#	var carPos: Vector2 = get_parent().get_node("PlayerCar").position
#	var netPos: Vector2 = get_parent().get_node("Net").position
#	# if possibleSpawnPos overalps with car, net, or other object/non-free space, move to
#	return possibleSpawnPos

#func _input(event : InputEvent):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_cancel"):
#			var isPaused : bool = get_tree().paused
#			get_tree().paused = !isPaused


func _on_NetDetectArea2D_score():
	
	pickupSpawnIncr += 1
	score += 5
	
	emit_signal("update_score", score)
	
	if score > highScore:
		highScore = score
		emit_signal("new_high_score")
		#TODO update highscore file, play sound and anim
	
	emit_signal("get_new_position")
	
	var _ball = ball.instance()
	_ball.position = newPos
	call_deferred("add_child", _ball) #??? not sure why this works and calling add_child(new_ball) doesn't
	
	if queuePickup == true && pickupSpawnIncr >= 2:
		var _pickup = pickup.instance()
		_pickup.position = nextPos
		call_deferred("add_child", _pickup)
		queuePickup = false
		pickupSpawnIncr = 0


func _on_HourglassPickup_pickup():
	
	score += 2
	
	queuePickup = true
	
	emit_signal("update_score", score)
	emit_signal("get_new_position")
	
	pickupSpawnIncr = 0
	nextPos = newPos #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn


func _on_SpawnCheck_newPosition(safePosition):
	
	newPos = safePosition
	
	#if queueBall == true:
	#	var _ball = ball.instance()
	#	_ball.position = safePosition
	#	call_deferred("add_child", _ball)
	#	queueBall = false
	
	#if queuePickup == true && pickupSpawnIncr >= 2:
	#	var _pickup = pickup.instance()
	#	_pickup.position = safePosition
	#	call_deferred("add_child", _pickup)
	#	queuePickup = false
	#	pickupSpawnIncr = 0
	#	#TODO: make pickup show after 2 goals scored only


func _on_Timer_timeout():
	#failstate
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
