#keep score, write highscore to file, and handle pausing and opening menus/displaying state

extends Node


class_name Main


export var pickup : PackedScene
export var ball : PackedScene

signal new_high_score
signal get_new_position
signal reset
signal update_score

var score : int = 0
var highScore : int = 100 #no JSON file yet, so just for now, this is the determiner for default hi-score
var queuePickup : bool
var pickupSpawnIncr : int = 0

var newPos  : Vector2
var nextPos : Vector2

var firstStart: bool = true

onready var SpawnCheck: Object = $SpawnCheck

func _ready():
	
	get_tree().paused = true
	
	$ScoreDisplay.text = "Score: 0"


func _on_Play_pressed():
	
	get_tree().paused = false
	$OpenMenu.show()
	
	if firstStart == true:
		queuePickup = true
		
		$PlayerCar.show()
		$Timer/TimerDisplay.show()
		$ScoreDisplay.show()
		$Environment/ToyBlocks.show()
		$Net.show()
		
		#add countdown timer func here, make it still pause, need coroutine maybe
		
		emit_signal("get_new_position")
		
		nextPos = newPos  #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn
		
		spawn_ball()
		
		firstStart = false
		
		AudioStreamSfxManager.play("res://sfx/yeah!.wav", false, -4)


func _on_OpenMenu_pressed():
	
	get_tree().paused = true
	
	$OpenMenu.hide()
	$MainMenu.show()


#func _input(event : InputEvent):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_cancel"):
#			var isPaused : bool = get_tree().paused
#			get_tree().paused = !isPaused


func spawn_ball():
	
	var _ball = ball.instance()
	
	if firstStart:
		pass
	else:
		emit_signal("get_new_position")
	
	_ball.position = newPos
	call_deferred("add_child", _ball)
	
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.8, 1.5)


func spawn_pickup():
	
	var _pickup = pickup.instance()
	
	emit_signal("get_new_position")
	
	_pickup.position = nextPos
	call_deferred("add_child", _pickup)
	
	queuePickup = false
	pickupSpawnIncr = 0
	
	AudioStreamSfxManager.play("res://sfx/glass ding.wav", true, -10)


func _on_NetDetectArea2D_score():
	
	pickupSpawnIncr += 1
	score += 5
	$ScoreDisplay.text = "Score: %s" % score
	
	#emit_signal("update_score", score)
	
	spawn_ball()
	
	if pickupSpawnIncr == 1: #inbetween 0 and 2, set the next position for pickup spawn workaround. 
		nextPos = newPos
	
	if queuePickup == true && pickupSpawnIncr >= 2:
		spawn_pickup()
	
	if score > highScore: #TODO write highscore to file
		highScore = score
		emit_signal("new_high_score")
		AudioStreamSfxManager.play("res://sfx/yeah!.wav", false, -4)


func _on_HourglassPickup_pickup():
	
	score += 2
	
	queuePickup = true
	
	emit_signal("update_score", score)
	emit_signal("get_new_position")
	
	AudioStreamSfxManager.play("res://sfx/crystal_twinkle.wav", true, 0.5)
	
	pickupSpawnIncr = 0
	nextPos = newPos #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn


func _on_SpawnCheck_newPosition(safePosition):
	
	newPos = safePosition


func _on_Timer_timeout():
	
	AudioStreamSfxManager.play("res://sfx/aww!.wav", false, -7)
	
	get_tree().paused = true
	
	$GameOver.show()


func _on_TryAgain_pressed():
	
	get_tree().paused = false
	
	$GameOver.hide()
	
	score = 0
	pickupSpawnIncr = 0
	queuePickup = true
	
	emit_signal("update_score", score)
	emit_signal("reset")
	
	AudioStreamSfxManager.play("res://sfx/yeah!.wav", false, -4)


func close_game():
	
	get_tree().quit()

func _on_Quit_pressed():
	
	close_game()

func _on_Exit_pressed():
	
	close_game()
