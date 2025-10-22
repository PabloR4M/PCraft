extends Node3D   # or whatever your root is

@onready var player = $PlayerCharacter           # must be in group "player"
@onready var pause_menu = $PauseMenu        # your Control scene

func _ready():
	await get_tree().physics_frame
	player = get_tree().get_first_node_in_group("player")
	pause_menu = get_tree().get_first_node_in_group("pause_menu")

	# 🔌 Conectar SEÑALES
	player.pause_requested.connect(_toggle_pause)
	pause_menu.continue_pressed.connect(_unpause)
	pause_menu.exit_pressed.connect(_exit_to_menu)

	pause_menu.hide()
func _toggle_pause():
	if get_tree().paused:
		_unpause()
	else:
		_pause()

func _pause():
	get_tree().paused = true
	pause_menu.show()
	pause_menu.grab_focus()          # ← el menú recibe el foco
	player.set_input_blocked(true)

func _unpause():
	get_tree().paused = false
	pause_menu.hide()
	player.set_input_blocked(false)

func _exit_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")
