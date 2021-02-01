extends Camera

export var min_zoom: float = 0.25
export var max_zoom: float = 1.25
export var zoom_factor: float = 5.0
export var zoom_duration: float = 0.2 
export var moveSpeed: float = 5.0

var _zoom_level := 70.0 setget _set_zoom_level

onready var tween: Tween = $Tween
var boundry := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	min_zoom = fov * min_zoom
	max_zoom = fov * max_zoom

func _set_zoom_level(value: float) -> void:
	_zoom_level = clamp(value, min_zoom, max_zoom)
	tween.interpolate_property(
		self,
		"fov",
		fov,
		_zoom_level,
		zoom_duration,
		tween.TRANS_SINE,
		tween.EASE_OUT
	)
	tween.start()

func _physics_process(delta):
	var input = Vector3()
	if current:
		if Input.is_action_pressed("move_forwards"):
			input.z -= 1
		if Input.is_action_pressed("move_backwards"):
			input.z += 1
		if Input.is_action_pressed("move_left"):
			input.x -= 1
		if Input.is_action_pressed("move_right"):
			input.x += 1
		input = input.normalized() * moveSpeed
		transform.origin.x = clamp(transform.origin.x + input.x, 0, boundry.x)
		transform.origin.z = clamp(transform.origin.z + input.z, 0, boundry.y)

func _unhandled_input(event):
	if current:
		if Input.is_action_pressed("zoom_in"):
			_set_zoom_level(_zoom_level - zoom_factor)
		if Input.is_action_pressed("zoom_out"):
			_set_zoom_level(_zoom_level + zoom_factor)
		
func set_max_boundry_pos(pos: Vector2):
	boundry = pos
