#split screen into quadrants, get car pos, find which quad it's in...
#pick a random quad that is free to spawn ball/pickup at a random location within said quad.

extends Area2D


onready var screenSize: Vector2 = get_viewport_rect().size

var midX : float
var midY : float

var q0 : Rect2 #top left
var q1 : Rect2 #top right
var q2 : Rect2 #bottom left
var q3 : Rect2 #bottom right

var quads : Array = [q0, q1, q2, q3]

var occupiedQuad : int

var unoccupiedQuad : Rect2
var pickupNextQuad : Rect2

var pickupActive : bool = false 

var quads2 : Array
var quads3 : Array

var possiblePosition : Vector2
var pickupPosition : Vector2


func _ready():
	
	get_quads()


func get_quads(): #construct quadrants from the screen
	
	midX = screenSize.x / 2
	midY = screenSize.y / 2
	
	quads[0] = Rect2(Vector2(1, 1) , Vector2(midX - 1, midY - 1)) #top left
	quads[1] = Rect2(Vector2(midX, 1) , Vector2(midX - 64, midY - 1)) #top right
	quads[2] = Rect2(Vector2(1, midY) , Vector2(midX - 1, midY - 1)) #bottom left
	quads[3] = Rect2(Vector2(midX,midY) , Vector2(midX - 64, midY - 1)) #bottom right


func find_point(point : Vector2, quad : Rect2) -> bool: #is a global point in quadrant?
	
	if point.x >= quad.position.x && point.y >= quad.position.y:
		
		if point.x <= quad.end.x && point.y <= quad.end.y:
			
			#var local : Vector2 = (quad.position - point) * -1
			#print("The point %s;" %point, " is within quadrant %s;" %quads.find(quad), " the local equivalent is %s" %local)
			
			return true
			
		else:
			#print("the point %s ;" %point , " is not within any quads")
			return false
		
	else:
		#print("the point %s ;" %point , " is not within any quads")
		return false


#NOTE: when trying to static type the return type, it throws a possible paths error. 
#not sure why. don't think it's a return var type issue. maybe i'm not understanding returns with for loops.
func in_which_quad(point : Vector2): #find which quad a given global point is in.
	
	#get_quads()
	
	for q in quads:
		
		if find_point(point, q):
			return q
	#return -1


func get_new_position(point : Vector2) -> Vector2: #pick a rand unoccupied quad and pick a local location within.
	
	occupiedQuad = quads.find(in_which_quad(point))
	
	if occupiedQuad >= 0:
		#BALL
		quads2 = quads.duplicate()
		quads2.remove(occupiedQuad)
		
		unoccupiedQuad = quads2.pick_random()
		
		#print("The unoccupied quad is %s;" %quads2.find(unoccupiedQuad), " with position and size of %s" %unoccupiedQuad)
		
		possiblePosition.x = rand_range(unoccupiedQuad.position.x + 132, unoccupiedQuad.end.x - 132)
		possiblePosition.y = rand_range(unoccupiedQuad.position.y + 132, unoccupiedQuad.end.y - 132)
		
		#PICKUP
		if pickupActive == false: #get new position for pickup only when needed
			quads3 = quads2.duplicate()
			quads3.remove(quads3.find(unoccupiedQuad))
			
			pickupNextQuad = quads3.pick_random()
			
			pickupPosition.x = rand_range(pickupNextQuad.position.x + 132, pickupNextQuad.end.x - 132)
			pickupPosition.y = rand_range(pickupNextQuad.position.y + 132, pickupNextQuad.end.y - 132)
			
			#print("The next pickup position will be %s" %pickupPosition, " in quad %s" %pickupNextQuad)
			
		elif pickupActive: #keep BALL from spawning in same quad/overlapping pickup if pickup is still on screen
			quads2 = quads.duplicate()
			quads2.remove(occupiedQuad)
			
			if quads[occupiedQuad] != pickupNextQuad:
				quads2.remove(quads2.find(pickupNextQuad))
			
			unoccupiedQuad = quads2.pick_random()
			
			possiblePosition.x = rand_range(unoccupiedQuad.position.x + 132, unoccupiedQuad.end.x - 132)
			possiblePosition.y = rand_range(unoccupiedQuad.position.y + 132, unoccupiedQuad.end.y - 132)
		
	else: #contingency if player outside of quads, changing this to spawning within a random quad might be better, could even have both objects spawn in exclusive quads
		
		#BALL
		possiblePosition.x = rand_range(132, screenSize.x - 230)
		possiblePosition.y = rand_range(132, screenSize.y - 132)
		
		#PICKUP
		pickupPosition.x = rand_range(132, screenSize.x - 230)
		pickupPosition.y = rand_range(132, screenSize.y - 132)
	
	#print("The next ball position will be %s" %possiblePosition, " in quad %s" %unoccupiedQuad)
	
	return possiblePosition
