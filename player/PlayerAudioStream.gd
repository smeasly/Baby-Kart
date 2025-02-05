#doesn't sound great. should use separate sounds in one clip and jump between, just need to add more loop starts/ends as exports and
#a few checks to tell the 'playhead' where to go.

extends AudioStreamPlayer


export var loopStartSeconds : float
export var loopEndSeconds : float

var firstPlay : bool = true
var lastPlay : bool = false

var length : float
const START : float = 0.0

var playhead : float

var queuePlay : bool = false #flag for receiving input from car


func _ready():
	
	length = self.stream.get_length()


func _process(_delta):
	
	#set lastPlay to TRUE upon no longer recieving input, if input recieved before end, set restart and go back to loop start
	if queuePlay && !playing: 
		firstPlay = true
		lastPlay = false
		play()
	
	if playing:
		playhead = get_playback_position()
		
		if firstPlay && playhead >= loopStartSeconds: #first play off, only relevant when using following conditional
			firstPlay = false
		
#		if !firstPlay && playhead < loopStartSeconds: #causes some unintended behaviour here, but may be useful for other applications
#			seek(loopStartSeconds)
		
		if queuePlay && playhead > loopEndSeconds: #if still looping, make sure loop goes back to start after leaving loop
			if lastPlay:
				seek(START)
				lastPlay = false
			else:
				seek(loopStartSeconds)
		
		if !queuePlay && playhead < loopEndSeconds: #when slowing down, go to outro point
			seek(loopEndSeconds)
		
		if !queuePlay && playhead > loopEndSeconds:
			lastPlay = true
			firstPlay = true
