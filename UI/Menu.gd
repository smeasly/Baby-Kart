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



func _ready():
	show()


func _on_Play_pressed():
	hide() #TODO change menu configuration from on start menu to pause/resume menu. ie: change play to resume, add try again button.
	$Play.text = "Resume"
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.5, 1.5)


#Options
func _on_Options_pressed():
	$OptionsContainer.show()
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.5, 1.5)

func _scroll_value(): #currently unused behaviour
	
	for index in carTypes.size():
		if carScroll.value == index:
			
			pass
	#var h: int = $OptionsContainer/OptionsPanel/CarSelect/3CarScrollBar.ratio
	#modColour = Color.from_hsv(h, 1, 1, 1)
	#$OptionsContainer/OptionsPanel/CarSelect/Sprite.self_modulate = modColour

func _on_CarScroll_value_changed(value):
	emit_signal("change_player_sprite", value)
	carSprite.texture = carTypes[carScroll.value]
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.5, 1.5)

func _on_SfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear2db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.01)	#where the float value = slider step
														#will fiddle with this later so make sure to change it accordingly!!

func _on_SfxSlider_drag_ended(_value_changed):
	AudioStreamSfxManager.play("res://sfx/glass ding.wav", true, -8, 0.5, 1.5)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear2db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.01)	#where the float value = slider step
															#will fiddle with this later so make sure to change it accordingly!!

func _on_ExitOptions_pressed():
	$OptionsContainer.hide()
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.5, 1.5)

#How To Play

func _on_HowToPlay_pressed():
	$HelpContainer.show() #if $HelpContainer/TextureRect/ExitHelp.emit_signal("pressed"):
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.5, 1.5)

func _on_ExitHelp_pressed():
	$HelpContainer.hide()
	AudioStreamSfxManager.play("res://sfx/cg_pop_1.wav", true, 0.0, 0.5, 1.5)
