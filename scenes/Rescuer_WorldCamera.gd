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

func move_location(input):
	input = input * moveSpeed
	transform.origin.x = clamp(transform.origin.x + input.x, 0, boundry.x)
	transform.origin.z = clamp(transform.origin.z + input.z, 0, boundry.y)
		
func set_world_location(worldSize, islandSpacing):
	boundry = Vector2(worldSize * islandSpacing, worldSize * islandSpacing)
	transform.origin.x = worldSize * islandSpacing / 2
	transform.origin.z = worldSize * islandSpacing / 2

func zoom_in():
	_set_zoom_level(_zoom_level - zoom_factor)

func zoom_out():
	_set_zoom_level(_zoom_level + zoom_factor)
