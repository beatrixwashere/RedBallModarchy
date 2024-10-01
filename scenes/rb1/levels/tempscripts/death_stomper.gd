extends RigidBody2D

@export var max_height: float
@export var min_height: float
var going_up:bool = false

func _ready():
	set_mass(65536)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not freeze:
		if self.position.y > min_height:
			going_up = true
		elif self.position.y < max_height:
			going_up = false
			
		if going_up:
			#constant_force = Vector2(0, -2)
			self.linear_velocity = Vector2(0, -2)
			move_and_collide(self.linear_velocity)
		
		#print(self.position.y)
	
	
