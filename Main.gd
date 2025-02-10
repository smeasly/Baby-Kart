#keep score, write highscore to file, and handle spawning, pausing and opening menus/displays

extends Node

class_name Main

const SAVE_PATH = "user://babykart_save.ini"

export var pickup : PackedScene
export var ball : PackedScene

signal reset

var score : int = 0
var highScore : int

var queueReset : bool
var queuePickup : bool
var pickupSpawnIncr : int = 0

var firstStart: bool = true


func _ready():
	get_tree().paused = true
	
	$AudioStreamPlayer.play()
	
	$ScoreDisplay.text = "Score: 0"
	
	load_score()
	
	$MainMenu/HighScoreDisplay.text = "Hi-Score: %s" % highScore


#BALL AND PICKUP
func spawn_ball():
	var _ball = ball.instance()
	
	if firstStart || queueReset:
		_ball.position = Vector2(512, 300)
		queueReset = false
		
	else:
		_ball.position = SpawnCheck.get_new_position($PlayerCar.position)
	
	call_deferred("add_child", _ball)
	
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.8, 1.5)

func spawn_pickup() -> void:
	SpawnCheck.pickupActive = true
	
	var _pickup = pickup.instance()
	
	_pickup.position = SpawnCheck.pickupPosition
	call_deferred("add_child", _pickup)
	
	#AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.8, 1.5)
	
	queuePickup = false
	pickupSpawnIncr = 0


#PAUSING/UNPAUSING THE GAME AND OPENING/CLOSING THE MENU
func _on_OpenMenu_pressed():
	get_tree().paused = true
	
	$OpenMenu.hide()
	$MainMenu.show()

func _input(event): #Pause w/ esc key
	if event is InputEventKey:
		
		if event.pressed && event.scancode == KEY_ESCAPE && !get_tree().paused:
			
			get_tree().paused = true
			
			$OpenMenu.hide()
			$MainMenu.show()
			
#unpausing with escape key
#doesn't work with pause mode, if main's pause process wasn't set to inherit, the following would cause unintended behaviour anyway.
#		elif event.pressed && event.scancode == KEY_ESCAPE && get_tree().paused && $MainMenu.visible: 
#			
#			get_tree().paused = false
#			
#			$MainMenu.hide()
#			
#		else:
#			pass


#SCORING
func _on_HourglassPickup_pickup():
	SpawnCheck.pickupActive = false
	
	score += 2
	$ScoreDisplay.text = "Score: %s" % score
	
	queuePickup = true
	
	AudioStreamSfxManager.play("res://sfx/crystal_twinkle.wav", true, -3)
	
	pickupSpawnIncr = 0

func _on_NetDetectArea2D_score():
	score += 5
	$ScoreDisplay.text = "Score: %s" % score
	
	AudioStreamSfxManager.play("res://sfx/cg_glass_ding.wav", true, -5, 1, 1.6)
	
	pickupSpawnIncr += 1
	
	spawn_ball()
	
	if queuePickup == true && pickupSpawnIncr >= 2:
		spawn_pickup()


#SAVING AND LOADING SCORE
func save_score():
	var config := ConfigFile.new()
	
	config.set_value("Highscores", "highscore", highScore)
	config.save(SAVE_PATH)
	
#	var error := config.save(SAVE_PATH)
#	if error != OK:
#		print("An error occured while saving: ", error)

func load_score():
	var config := ConfigFile.new()
	
	var error := config.load(SAVE_PATH)
	
	if error == OK:
		highScore = config.get_value("Highscores", "highscore")
	elif error == ERR_FILE_NOT_FOUND: #Creates a save when one does not already exist
		highScore = 42
		save_score()
	else:
		printerr("An error occured while loading highscore: ", error)

func check_highscore():
	if score > highScore:
		highScore = score 
		return true
	else:
		return false


#FAILSTATE
func _on_Timer_timeout():
	$AudioStreamPlayer.stop()
	$OpenMenu.hide()
	
	$GameOver/HighScoreDisplay.text = "Hi-Score: %s" % highScore
	
	if check_highscore() == true:
		$GameOver/LabelFinalScore.text = "You Set A New Hi-Score!: %s" % score
		$MainMenu/HighScoreDisplay.text = "Hi-Score: %s" % highScore
		AudioStreamSfxManager.play("res://sfx/cg_yeah.wav", false, -7)
		save_score()
		
	else:
		$GameOver/LabelFinalScore.text = "Your Final Score: %s" % score
		AudioStreamSfxManager.play("res://sfx/cg_aww.wav", false, -7)
	
	get_tree().paused = true
	
	$GameOver.show()


#START,RESTART, AND CLOSE GAME
func countdown(): #Countdown at the start of the round
	$RichTextLabel.show() #I want to add some text effects to this label, but syncing it with the timer and displaying correctly is a pain
	
	$OpenMenu.hide()
	
	$AudioStreamPlayer.stop()
	
	get_tree().paused = true
	
	yield(get_tree().create_timer(0.5), "timeout")
	$RichTextLabel.bbcode_text = "[center]3[/center]"
	AudioStreamSfxManager.play("res://sfx/cg_cowbell.wav", false, -5)
	
	yield(get_tree().create_timer(1.0), "timeout")
	$RichTextLabel.bbcode_text = "[center]2[/center]"
	AudioStreamSfxManager.play("res://sfx/cg_cowbell.wav", false, -5)
	
	yield(get_tree().create_timer(1.0), "timeout")
	$RichTextLabel.bbcode_text = "[center]1[/center]"
	AudioStreamSfxManager.play("res://sfx/cg_cowbell.wav", false, -5)
	
	yield(get_tree().create_timer(1.0), "timeout")
	$RichTextLabel.bbcode_text = "[center]Go![/center]"
	AudioStreamSfxManager.play("res://sfx/cg_yeah.wav", false, -5)
	
	get_tree().paused = false
	
	$AudioStreamPlayer.play()
	
	$OpenMenu.show()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	$RichTextLabel.hide()
	$RichTextLabel.bbcode_text = ""

func restart_game(): 
	countdown()
	
	score = 0
	pickupSpawnIncr = 0
	queuePickup = true
	
	$GameOver.hide()
	$MainMenu.hide()
	$PlayerCar/ParticleTrail.hide()
	
	$ScoreDisplay.text = "Score: %s" % score
	
	emit_signal("reset") 
	
	queueReset = true
	spawn_ball()

func close_game():
	get_tree().quit()


#GAME-OVER SCREEN
func _on_TryAgain_pressed(): #Try again button after game-over
	restart_game()

func _on_Quit_pressed(): #Quit button
	close_game()


#MAIN MENU
func _on_Play_pressed():
	get_tree().paused = false
	$OpenMenu.show()
	
	if firstStart == true: #change menu elements to reflect game state
		
		queuePickup = true
		
		$PlayerCar.show()
		$Timer/TimerDisplay.show()
		$ScoreDisplay.show()
		$Environment/ToyBlocks.show()
		$Net.show()
		
		countdown()
		
		spawn_ball()
		
		firstStart = false

func _on_Restart_pressed(): #Restart button on main menu
	
	if check_highscore() == true:
		AudioStreamSfxManager.play("res://sfx/cg_yeah.wav", false, -7)
		save_score()
		
	else:
		$GameOver/LabelFinalScore.text = "Your Final Score: %s" % score
		AudioStreamSfxManager.play("res://sfx/cg_aww.wav", false, -7)
	
	restart_game()

func _on_Exit_pressed(): #Quit button
	close_game()
