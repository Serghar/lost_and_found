extends Spatial

# look stats
var lookSensitivity: float = 15.0
var minLookAngle: float = -20
var maxLookAngle: float = 75.0

# vectors
var mouseDelta = Vector2()

# components
onready var player = get_parent()	

func _process(delta):
	# Get rotation to apply to the camera and plater
	var rot = Vector3(mouseDelta.y, mouseDelta.x, 0) * lookSensitivity * delta
	
	# camera vertical rotation
	rotation_degrees.x += rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
	
	# player horizontal rotation
	player.rotation_degrees.y -= rot.y
	
	# clear the mouse movement vector
	mouseDelta = Vector2()
	
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
