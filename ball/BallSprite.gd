extends Sprite

var startRotation:float

func _ready():
	startRotation = get_global_rotation_degrees()

func _process(_delta):
	set_global_rotation_degrees(startRotation)
