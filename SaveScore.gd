#class_name SaveHighScore

extends Node

const SAVE_PATH := "user://highscore.ini"

var highScore : int

func save_score() -> void:
	var config := ConfigFile.new()
	
	config.set_value("Highscores", "highscore", highScore)
	
	var error := config.save(SAVE_PATH)
	if error:
		print("An error occured while saving: ", error)

func load_score():
	var config := ConfigFile.new()
	
	var error := config.load(SAVE_PATH)
	if error:
		print("An error occured while loading: ", error)
	
	highScore = config.get_value("Main", "highScore", highScore)


#func save_score() -> void:
		#ResourceSaver.save(SAVE_PATH, self)

#static func load_score() -> Resource:
#	if ResourceLoader.exists(SAVE_PATH):
#		return load(SAVE_PATH)
#	return null
