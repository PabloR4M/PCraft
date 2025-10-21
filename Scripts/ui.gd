extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var next_button = $NextLevelButton
const SAVE_PATH = "user://player_data.tres"

var total_pieces = 0
var current_score = 0

func _ready():
	next_button.pressed.connect(_on_next_pressed)
	update_ui()
	# Contar cuántos slots hay en la escena
	var slots = get_tree().get_nodes_in_group("slots")
	set_total_pieces(slots.size())
	print("UI iniciado. Total de slots: ", total_pieces)
	print("ScoreLabel encontrado: ", score_label != null)

func set_total_pieces(total: int):
	total_pieces = total
	update_ui()

func save_progress():
	var data = PlayerData.new()
	data.pc_build_completed = true
	ResourceSaver.save(data, SAVE_PATH)
	print("Progreso guardado: nivel completado")

func add_point():
	current_score += 1
	update_ui()
	if current_score >= total_pieces:
		show_completion()

func update_ui():
	score_label.text = "Piezas: %d / %d" % [current_score, total_pieces]

func show_completion():
	score_label.text = "¡Nivel completado!"
	next_button.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	save_progress()
func _on_next_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")
