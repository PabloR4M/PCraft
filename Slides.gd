extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var player = get_tree().get_first_node_in_group("player")

var slides: Dictionary = {
	"CPU": preload("res://Image/CPU.jpg"),
	"RAM": preload("res://Image/RAM.jpg"),
	"GPU": preload("res://Image/GPU.jpg"),
	"PSU": preload("res://Image/PSU.jpg"),
	"MOTHERBOARD": preload("res://Image/MOTHERBOARD.jpg"),
	"COOLER": preload("res://Image/Cooler.jpg")
}

var current_type = ""
var default_timer: SceneTreeTimer = null            # timer para default

func _ready():
	update_slide()

func _process(_delta):
	if player and player.holding_object:
		var part_type = player.holding_object.part_type
		if part_type != current_type:
			cancel_default_timer()
			update_slide(part_type)
	else:
		if current_type != "":
			cancel_default_timer()
			default_timer = get_tree().create_timer(5)
			default_timer.timeout.connect(_show_default)
			current_type = ""

func _show_default():
	update_slide("")
				  # muestra default después del delay

func cancel_default_timer():
	if default_timer != null:
		default_timer.timeout.disconnect(_show_default)
		default_timer = null

func update_slide(part_type = ""):
	var mat := StandardMaterial3D.new()

	if part_type == "" or not slides.has(part_type):
		mat.emission_texture = preload("res://Image/1.JPG")
	else:
		mat.emission_texture = slides[part_type]

	mat.emission_enabled = true
	mat.emission_energy = 1
	mat.albedo_texture = mat.emission_texture

	mesh.material_override = mat
	current_type = part_type
