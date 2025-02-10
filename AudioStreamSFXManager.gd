extends Node


func play(streamPath: String, randomize_pitch: bool = false, volume: float = 0.0, min_pitch: float = 1.0, max_pitch: float = 1.2) -> void:
	var audioStreamPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
	var bus = "SFX"
	var pitch: float
	
	if randomize_pitch: 
		pitch = min_pitch + (max_pitch - min_pitch) * randf()
		if !(pitch > 0.0): #keep pitch from dropping below 0.0
			pitch = 0.5
	else:
		pitch = 1.0
	
	pause_mode = audioStreamPlayer.PAUSE_MODE_PROCESS #if not set to process, audio streams do not free themselves from memory when scene-tree is paused
	audioStreamPlayer.bus = bus
	audioStreamPlayer.stream = load(streamPath)
	audioStreamPlayer.pitch_scale = pitch
	audioStreamPlayer.volume_db = volume
	
	call_deferred("add_child", audioStreamPlayer)
	yield(audioStreamPlayer, "tree_entered")
	audioStreamPlayer.play()
	yield(audioStreamPlayer, "finished")
	audioStreamPlayer.queue_free()
