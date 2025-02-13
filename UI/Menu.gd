extends Control


var green_car = preload("res://player/car.png")
var blue_car = preload("res://player/car2.png")
var red_car = preload("res://player/car3.png")

var carTypes = [green_car, blue_car, red_car]

onready var carScroll = $OptionsContainer/OptionsPanel/CarSelect/CarScroll
onready var carSprite = $OptionsContainer/OptionsPanel/CarSelect/Sprite
onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

signal change_player_sprite

var startedFlag : bool = false

export var popSound : AudioStreamSample
export var dingSound : AudioStreamSample

func _ready():
	show()


func _on_Play_pressed():
	hide() #TODO change menu configuration from on start menu to pause/resume menu. ie: change play to resume, add try again button.
	$Play.text = "Resume"
	$Exit.rect_size.x = 128
	$Restart.show()
	startedFlag = true
	AudioStreamSfxManager.play(popSound, true, 0.0, 0.5, 1.5)


#OPTIONS
func _on_Options_pressed():
	$OptionsContainer.show()
	AudioStreamSfxManager.play(popSound, true, 0.0, 0.5, 1.5)

func _on_CarScroll_value_changed(value):
	emit_signal("change_player_sprite", value)
	carSprite.texture = carTypes[carScroll.value]
	set_car_select_text(value)
	AudioStreamSfxManager.play(popSound, true, 0.0, 0.5, 1.5)

func set_car_select_text(value : int):
	match value:
		0: #GREEN_CAR, default balanced
			$OptionsContainer/OptionsPanel/CarSelect/CarStatLabel.text = """Green Car:
				
			- Balanced turning.
			
			- Balanced speed."""
			return
		
		1: #BLUE_CAR, better turning, worse speed
			$OptionsContainer/OptionsPanel/CarSelect/CarStatLabel.text = """Blue Car:
				
			- Better turning.
			
			- Worse speed."""
			return
		
		2: #RED_CAR, better speed, worse turning
			$OptionsContainer/OptionsPanel/CarSelect/CarStatLabel.text = """Red Car:
				
			- Better speed.
			
			- Worse turning."""
			return

func _on_SfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear2db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.01)

func _on_SfxSlider_drag_ended(_value_changed):
	AudioStreamSfxManager.play(dingSound, true, -8, 0.5, 1.5)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear2db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.01)

func _on_ExitOptions_pressed():
	$OptionsContainer.hide()
	AudioStreamSfxManager.play(popSound, true, 0.0, 0.5, 1.5)


#HOW TO PLAY
func _on_HowToPlay_pressed():
	$OptionsContainer.hide()
	$HelpContainer.show() #if $HelpContainer/TextureRect/ExitHelp.emit_signal("pressed"):
	AudioStreamSfxManager.play(popSound, true, 0.0, 0.5, 1.5)

func _on_ExitHelp_pressed():
	$HelpContainer.hide()
	AudioStreamSfxManager.play(popSound, true, 0.0, 0.5, 1.5)
