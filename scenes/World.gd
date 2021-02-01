extends Spatial

# Grid size and island count
var worldSize = 10
var numberIslands = 7
var islandSpacing = 40

# Val: IslandRef
var islands = {}

onready var worldCamera: Camera = $WorldCamera

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_islands()
	set_world_camera()
	
func generate_islands():
	var island_scene = load("res://scenes/Island.tscn")
	for n in range(numberIslands):
		# Get a new island value not currently avaliable
		var val = -1
		while val < 0 and not islands.has(val):
			val = rng.randi_range(0, worldSize * worldSize - 1)

		# Generate island at respective position and add to islands list
		var island = island_scene.instance()
		island.set_rng_ref(rng)
		var position2D = get_idx_position2D(val, worldSize)
		island.transform.origin = Vector3(
			position2D.x * islandSpacing,
			0,
			position2D.y * islandSpacing
		)
		islands[val] = island
		get_node("Islands").add_child(island)

func set_world_camera():
	worldCamera.set_max_boundry_pos(Vector2(worldSize * islandSpacing, worldSize * islandSpacing))
	worldCamera.transform.origin.x = worldSize * islandSpacing / 2
	worldCamera.transform.origin.z = worldSize * islandSpacing / 2

# returns idx positions in array/coordinates for island
func get_idx_position2D(val, size: int) -> Vector2:
	var posY = val / size
	var posX = val % size
	return Vector2(posX, posY)
