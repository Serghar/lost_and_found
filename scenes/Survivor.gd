extends KinematicBody

# remote sync values
puppet var puppet_vel = Vector3()
puppet var puppet_transform: Transform

# physics
var moveSpeed: float = 5.0
var jumpForce: float = 10.0
var gravity: float = 15.0

var vel = Vector3()

# components
onready var camera: Camera = get_node("CameraOrbit").get_child(0)


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		camera.make_current()

func _physics_process(delta):
	vel.x = 0
	vel.z = 0
	
	var input = Vector3()
	if is_network_master():
		if Input.is_action_pressed("move_forwards"):
			input.z += 1
		if Input.is_action_pressed("move_backwards"):
			input.z -= 1
		if Input.is_action_pressed("move_left"):
			input.x += 1
		if Input.is_action_pressed("move_right"):
			input.x -= 1
		input = input.normalized()
	
		var dir = (transform.basis.z * input.z + transform.basis.x * input.x)
		vel.x = dir.x * moveSpeed
		vel.z = dir.z * moveSpeed
	
		# gravity
		vel.y -= gravity * delta
	
		# jump input
		if Input.is_action_pressed("jump") and is_on_floor():
			vel.y = jumpForce
		
		rset("puppet_vel", vel)
	else:
		vel = puppet_vel
	
	# move along the current velocity
	vel = move_and_slide(vel, Vector3.UP)
	
	# Try to address location sync issues
	if is_network_master():
		rset("puppet_transform", transform)
	elif not transform.origin == puppet_transform.origin:
		transform = puppet_transform

func set_spawn_location(location):
	transform.origin = location
