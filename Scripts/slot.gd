# Slot.txt  – versión final con BLOQUEO si ya está ocupado
extends Area3D
class_name PartSlot

@export_enum("CPU","RAM","GPU","SSD","PSU","MOTHERBOARD","COOLER") var expected_type:String = "CPU"
@onready var placement_point: Node3D = $PlacementPoint
@export var required_slot: NodePath          # nodo del que depende
@export_enum("CPU","RAM","GPU","SSD","PSU","MOTHERBOARD","COOLER") var required_type_in_slot: String = ""
signal slot_occupied_changed(occupied)
var occupied: bool = false                   # <- flag clave

@onready var _req_slot: PartSlot = get_node_or_null(required_slot)

func _ready():
	if not is_in_group("slots"):
		add_to_group("slots")
	if _req_slot:
		_req_slot.slot_occupied_changed.connect(_on_parent_changed)
		await get_tree().physics_frame
		_on_parent_changed(_req_slot.occupied)

func _on_parent_changed(parent_occupied: bool):
	var active = parent_occupied
	visible = active
	process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
	monitoring = active
	set_physics_process(active)
	$CollisionShape3D.set_deferred("disabled", not active)

func try_place(player) -> bool:
	# 1. ¿Slot ya ocupado?  ->  BLOQUEO TOTAL
	if occupied:
		print(name, " ya está ocupado. No se puede colocar.")
		return false

	# 2. ¿Dependencia no cumplida?
	if _req_slot and not _req_slot.occupied:
		print(name, " bloqueado: falta ", _req_slot.name)
		return false

	# 3. ¿Jugador tiene algo?
	if not player.holding_object:
		return false

	var held = player.holding_object
	if held.part_type != expected_type:
		return false

	# 4. Colocar
	held.global_position = placement_point.global_position
	held.global_rotation = placement_point.global_rotation
	held.reparent(self)
	if held is RigidBody3D:
		held.freeze = true
		held.collision_layer = 0
		held.collision_mask = 0
	held.set_deferred("input_ray_pickable", false)

	occupied = true
	emit_signal("slot_occupied_changed", true)
	player.holding_object = null
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.add_point()
	print("Pieza ", held.name, " encajada en ", name)
	return true

func try_unpick(player) -> bool:
	var child: Node3D = null
	for c in get_children():
		if c is Part:
			child = c
			break
	if child == null:
		return false

	child.reparent(get_tree().current_scene)
	var drop_pos = placement_point.global_position + placement_point.global_basis.z * 0.3
	child.global_position = drop_pos
	child.global_rotation = placement_point.global_rotation
	if child is RigidBody3D:
		child.freeze = false
		child.collision_layer = 1
		child.collision_mask = 1
	child.set_deferred("input_ray_pickable", true)

	player.holding_object = child
	child.reparent(player.hand_position)
	child.position = Vector3.ZERO
	child.rotation = Vector3.ZERO
	if child is RigidBody3D:
		child.freeze = true
		child.collision_layer = 0
		child.collision_mask = 0

	occupied = false
	emit_signal("slot_occupied_changed", false)
	return true
