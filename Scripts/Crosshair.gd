extends CanvasLayer

@onready var crosshair: TextureRect = $TextureRect
@onready var player = get_tree().get_first_node_in_group("player")

var default_scale := Vector2(.25, .25)
var hover_scale   := Vector2(.50, .50)

func _ready():
	print("Crosshair listo. Player encontrado: ", player != null)
	if player and player.ray:
		print("RayCast encontrado: ", player.ray)
	else:
		print("⚠ Player o ray no encontrados")

func _process(_delta):
	if not player or not player.ray:
		print("Player o ray NULOS")
		return

	var target = player.ray.get_collider()
	print("Raycast tocando: ", target)

	var can_highlight = false
	if target:
		print("  - target es: ", target.name, " (clase: ", target.get_class(), ")")
		if target.is_in_group("pickable"):
			print("  - está en grupo 'pickable'")
			can_highlight = true
		elif target is PartSlot:
			print("  - es un PartSlot")
			if player.holding_object:
				print("    - jugador sostiene ", player.holding_object.name, " tipo: ", player.holding_object.part_type)
				can_highlight = (player.holding_object.part_type == target.expected_type)
				print("    - highlight = ", can_highlight)
			else:
				print("    - jugador no sostiene nada")
				# Buscar pieza dentro del slot
				for c in target.get_children():
					if c is Part:
						can_highlight = true
						print("    - slot contiene pieza: ", c.name)
						break
	else:
		print("  - target es NULO")

	var scale_target = hover_scale if can_highlight else default_scale
	crosshair.scale = lerp(crosshair.scale, scale_target, 10.0 * get_process_delta_time())
