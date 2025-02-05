#keep score, write highscore to file, and handle pausing and opening menus/displaying state

extends Node


class_name Main


export var pickup : PackedScene
export var ball : PackedScene

signal new_high_score
signal get_new_position
signal reset

var score : int = 0
var highScore : int = 150 #no JSON file yet, so just for now, this is the determiner for default hi-score
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
		
		countdown() #add countdown timer func here, make it still pause, need coroutine maybe
		
		emit_signal("get_new_position")
		nextPos = newPos  #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn
		
		spawn_ball()
		
		firstStart = false


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


func _on_NetDetectArea2D_score():
	
	score += 5
	$ScoreDisplay.text = "Score: %s" % score
	
	AudioStreamSfxManager.play("res://sfx/cg_glass_ding.wav", true, -5, 1, 1.6)
	
	pickupSpawnIncr += 1
	
	spawn_ball()
	
	if pickupSpawnIncr == 1: #inbetween 0 and 2, set the next position for pickup spawn workaround. 
		nextPos = newPos #kind of hacky. save a position on pickup, use this pos for next pickups spawn to avoid overlapping with ball spawn
	
	if queuePickup == true && pickupSpawnIncr >= 2:
		spawn_pickup()
	
	if score > highScore: #TODO write highscore to file
		highScore = score 
		emit_signal("new_high_score")
		AudioStreamSfxManager.play("res://sfx/cg_yeah.wav", false, -7)


func _on_HourglassPickup_pickup():
	
	score += 2
	$ScoreDisplay.text = "Score: %s" % score
	
	queuePickup = true
	
	emit_signal("get_new_position")
	
	AudioStreamSfxManager.play("res://sfx/crystal_twinkle.wav", true, -4)
	
	if score > highScore: #TODO write highscore to file
		highScore = score
		emit_signal("new_high_score")
		AudioStreamSfxManager.play("res://sfx/cg_yeah.wav", false, -7)
	
	pickupSpawnIncr = 0


func _on_SpawnCheck_newPosition(safePosition):
	
	newPos = safePosition


func _on_Timer_timeout():
	
	AudioStreamSfxManager.play("res://sfx/cg_aww.wav", false, -7)
	
	get_tree().paused = true
	
	$GameOver/VBoxContainer/LabelFinalScore.text = "Your Score: %s" % score
	
	$GameOver.show()


func _on_TryAgain_pressed():
	
	countdown()
	
	$GameOver.hide()
	
	score = 0
	pickupSpawnIncr = 0
	queuePickup = true
	
	$ScoreDisplay.text = "Score: %s" % score
	
	emit_signal("reset")


func countdown():
	
	$RichTextLabel.show()
	get_tree().paused = true
	
	yield(get_tree().create_timer(0.5), "timeout")
	$RichTextLabel.bbcode_text = "[center]3[/center]"
	AudioStreamSfxManager.play("res://sfx/cg_cowbell.wav", false, 0.8)
	
	yield(get_tree().create_timer(1.0), "timeout")
	$RichTextLabel.bbcode_text = "[center]2[/center]"
	AudioStreamSfxManager.play("res://sfx/cg_cowbell.wav", false, 0.8)
	
	yield(get_tree().create_timer(1.0), "timeout")
	$RichTextLabel.bbcode_text = "[center]1[/center]"
	AudioStreamSfxManager.play("res://sfx/cg_cowbell.wav", false, 0.8)
	
	yield(get_tree().create_timer(1.0), "timeout")
	$RichTextLabel.bbcode_text = "[center]Go![/center]"
	AudioStreamSfxManager.play("res://sfx/cg_yeah.wav", false, -5)
	get_tree().paused = false
	
	yield(get_tree().create_timer(0.5), "timeout")
	$RichTextLabel.hide()
	$RichTextLabel.bbcode_text = ""


func close_game():
	
	get_tree().quit()

func _on_Quit_pressed():
	
	close_game()

func _on_Exit_pressed():
	
	close_game()
