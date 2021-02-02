extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$WorldCamera.make_current()

func _physics_process(delta):

	if $WorldCamera.current:		
		var input = Vector3()
		if Input.is_action_pressed("move_forwards"):
			input.z -= 1
		if Input.is_action_pressed("move_backwards"):
			input.z += 1
		if Input.is_action_pressed("move_left"):
			input.x -= 1
		if Input.is_action_pressed("move_right"):
			input.x += 1
		$WorldCamera.move_location(input.normalized())

func _unhandled_input(event):
	if $WorldCamera.current:
		if Input.is_action_pressed("zoom_in"):
			$WorldCamera.zoom_in()
		if Input.is_action_pressed("zoom_out"):
			$WorldCamera.zoom_out()
		
func set_world_location(worldSize, islandSpacing):
	$WorldCamera.set_world_location(worldSize, islandSpacing)
