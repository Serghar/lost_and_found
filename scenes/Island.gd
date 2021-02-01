extends Spatial

var rng = RandomNumberGenerator.new()
onready var trees = [
	load("res://scenes/env/Tree1.tscn"),
	load("res://scenes/env/Tree2.tscn"),
	load("res://scenes/env/Tree3.tscn"),
	load("res://scenes/env/Tree4.tscn"),
]

var hasPlayer: bool = false
var islandsize = 26 # 26 whats? no one knows....

# Called when the node enters the scene tree for the first time.
func _ready():
	var num_trees = rng.randi_range(1, 8)
	for n in range(num_trees):
		var randx = rng.randi_range(0, islandsize) - islandsize / 2
		var randz = rng.randi_range(0, islandsize) - islandsize / 2
		add_tree(Vector3(randx, 0, randz))

func add_tree(location_offset: Vector3):
	var tree = trees[rng.randi_range(0, trees.size() - 1)].instance()
	tree.transform = transform
	tree.transform.origin += location_offset
	get_node("Terrain").add_child(tree)

func set_rng_ref(ref):
	rng = ref
