extends Control


var green_car = preload("res://player/car.png")
var blue_car = preload("res://player/car2.png")
var red_car = preload("res://player/car3.png")

var carTypes = [green_car, blue_car, red_car]

onready var carScroll = $OptionsContainer/OptionsPanel/CarSelect/CarScroll
onready var carSprite = $OptionsContainer/OptionsPanel/CarSelect/Sprite

signal change_player_sprite


func _ready():
	show()


func _on_Play_pressed():
	hide() #TODO change menu configuration from on start menu to pause/resume menu. ie: change play to resume, add try again button.


#Options

func _on_Options_pressed():
	$OptionsContainer.show()

func _scroll_value(): 
	
	for index in carTypes.size():
		if carScroll.value == index:
			
			pass
	#var h: int = $OptionsContainer/OptionsPanel/CarSelect/3CarScrollBar.ratio
	#modColour = Color.from_hsv(h, 1, 1, 1)
	#$OptionsContainer/OptionsPanel/CarSelect/Sprite.self_modulate = modColour

func _on_CarScroll_value_changed(value):
	emit_signal("change_player_sprite", value)
	carSprite.texture = carTypes[carScroll.value]

func _on_ExitOptions_pressed():
	$OptionsContainer.hide()


#How To Play

func _on_HowToPlay_pressed():
	$HelpContainer.show() #if $HelpContainer/TextureRect/ExitHelp.emit_signal("pressed"):

func _on_ExitHelp_pressed():
	$HelpContainer.hide()



