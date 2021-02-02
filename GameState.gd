extends Node

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 3

enum Roles {SURVIVE, RESCUE}

var peer = null

# Name for my player.
var player_name = "Player"
var role = Roles.SURVIVE

# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal server_closed()
signal game_ended()
signal game_error(what)

var rng = RandomNumberGenerator.new()

func _process(delta):
	if has_node("/root/World"):
		if Input.is_action_pressed("disconnect"):
			leave_active_game()

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			close_server()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	close_server()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(playerIds):
	# Change scene.
	var world = load("res://scenes/World.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()
	
	var survivor_scene = load("res://scenes/Survivor.tscn")
	var rescuer_scene = load("res://scenes/Rescuer.tscn")
	
	# Assign a random player from the list as the rescuer and spawn into the world
	var rescuerIdx = rng.randi_range(0, playerIds.size() - 1)
	var rescuerId = playerIds[rescuerIdx]
	playerIds.remove(rescuerIdx)
	if get_tree().get_network_unique_id() == rescuerId:
		role = Roles.RESCUE
	else:
		role = Roles.SURVIVE
	
	var rescuer = rescuer_scene.instance()
	rescuer.set_name(str(rescuerId))
	rescuer.set_world_location(world.worldSize, world.islandSpacing)
	rescuer.set_network_master(rescuerId)
	world.get_node("Players").add_child(rescuer)

	# Spawn the remainder of players as survivors
	for p_id in playerIds:
		# Get a random island from world and set it as player spawn
		var islandIds = world.islands.keys()
		var selectedIslandId = islandIds[rng.randi_range(0, islandIds.size() - 1)]
		var selectedIsland = world.islands[selectedIslandId]
		selectedIsland.hasPlayer = true
		var spawn_pos = selectedIsland.transform.origin

		var player = survivor_scene.instance()
		if role == Roles.RESCUE:
			player.visible = false # Hide players from rescuers
		player.set_name(str(p_id))
		player.set_spawn_location(spawn_pos)
		player.set_network_master(p_id)
		world.get_node("Players").add_child(player)

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())
	
	# TODO: figure out why server player isn't added to list
	# Potentially with a dedicated server we will never need to include the server as a character
	var playerIdsWithServer = players.keys()
	playerIdsWithServer.append(1)
	for p in players:
		rpc_id(p, "pre_start_game", playerIdsWithServer)

	pre_start_game(playerIdsWithServer)

remote func end_game(success):
	if get_tree().is_network_server():
		for p in players:
			rpc_id(p, "end_game", success)
	var endGameUI = get_tree().get_root().get_node("World").get_node("EndGame")
	endGameUI.make_visible(success)

func return_to_lobby():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()
	get_tree().get_root().get_node("Lobby").show()

func close_server():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("server_closed")
	players.clear()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func leave_active_game():
	peer.close_connection()
	close_server()

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
