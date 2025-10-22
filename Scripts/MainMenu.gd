extends Control
const SAVE_PATH = "user://player_data.tres"

func _ready():
	$StartButton.pressed.connect(_on_start)
	$ExitButton.pressed.connect(_on_exit)

	if FileAccess.file_exists(SAVE_PATH):
		var data = ResourceLoader.load(SAVE_PATH) as PlayerData
		

func _on_start():
	# Ir al nivel 1
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_exit():
	# Cerrar juego
	get_tree().quit()
