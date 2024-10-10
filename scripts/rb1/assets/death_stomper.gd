extends RigidBody2D
## handles the crushers at the start of level 4

@export var max_height: float
@export var min_height: float
var going_up: bool = false


func _ready():
	mass = 65536


func _physics_process(delta: float) -> void:
	if not freeze:
		if position.y > min_height:
			going_up = true
		elif position.y < max_height:
			going_up = false
			
		if going_up:
			#constant_force = Vector2(0, -2)
			linear_velocity = Vector2(0, -2)
			move_and_collide(linear_velocity)
		
		#print(self.position.y)
