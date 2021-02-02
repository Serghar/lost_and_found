extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func make_visible(success):
	if success:
		$Connect/Message.text = "you won, congrats!!"
	else:
		$Connect/Message.text = "you lost better luck next time..."
	visible = true

func _on_Return_pressed():
	gamestate.return_to_lobby()

func _on_Quit_pressed():
	gamestate.leave_active_game()
