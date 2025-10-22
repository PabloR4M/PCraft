extends CharacterBody3D
class_name PlayerCharacter

# ---- NODES ----
@onready var camera = $Camera3D
@onready var ray = $Camera3D/RayCast3D
@onready var hand_position = $Camera3D/HandPosition

# ---- SETTINGS ----
var mouse_sensitivity = 0.002

# ---- STATE ----
var holding_object: Part = null
var input_enabled = true          # ← NEW: block look while paused

# ---- SIGNALS ----
signal pause_requested()          # ← NEW: level will open the menu

# ------------------------------------------------------------------
#  LIFE-CYCLE
# ------------------------------------------------------------------
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ------------------------------------------------------------------
#  INPUT
# ------------------------------------------------------------------
func _input(event):
	# 1) PAUSE TOGGLE  (ESC)
	if event.is_action_pressed("ui_cancel"):
		emit_pause_request()
		return   # consume ESC so it doesn't leak

	# 2) LOOK  (only if not paused)
	if input_enabled and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	# 3) INTERACT  (only if not paused)
	if input_enabled and event.is_action_pressed("interact"):
		handle_interact()

# ------------------------------------------------------------------
#  PAUSE  (player only emits; Level owns the menu)
# ------------------------------------------------------------------
func emit_pause_request() -> void:
	emit_signal("pause_requested")

# Called by the Level when the menu opens/closes
func set_input_blocked(blocked: bool) -> void:
	input_enabled = not blocked
	if blocked:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ------------------------------------------------------------------
#  INTERACTION  (unchanged logic)
# ------------------------------------------------------------------
func handle_interact() -> void:
	# 1) Drop to world  (no ray hit)
	if holding_object and not ray.is_colliding():
		try_drop()
		return

	# 2) Slot interaction  (ray hit)
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit is PartSlot:
			if holding_object:
				if hit.try_place(self): return
			else:
				if hit.try_unpick(self): return
		elif hit.is_in_group("pickable") and holding_object == null:
			try_pickup()

# ------------------------------------------------------------------
#  PICK / DROP  (unchanged)
# ------------------------------------------------------------------
func try_pickup() -> void:
	if ray.is_colliding():
		var body = ray.get_collider()
		if body is Part:
			holding_object = body as Part
			body.reparent(hand_position)
			body.position = Vector3.ZERO
			body.rotation = Vector3.ZERO
			if body is RigidBody3D:
				body.freeze = true
				body.collision_layer = 0
				body.collision_mask = 0

func try_drop() -> void:
	if not holding_object: return

	var drop_pos: Vector3
	if ray.is_colliding():
		drop_pos = ray.get_collision_point() - ray.get_collision_normal() * 0.1
	else:
		drop_pos = hand_position.global_position - camera.global_transform.basis.z * 0.5

	holding_object.reparent(get_tree().current_scene)
	holding_object.global_position = drop_pos
	holding_object.global_rotation = camera.global_rotation
	if holding_object is RigidBody3D:
		holding_object.freeze = false
		holding_object.collision_layer = 1
		holding_object.collision_mask = 1
	holding_object = null

# Called by slots when they auto-place or auto-remove a piece
func drop_from_slot() -> void:
	holding_object = null

# ------------------------------------------------------------------
#  MOVEMENT  (unchanged)
# ------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if not input_enabled: return   # don't walk while paused

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity = direction * 5.0
	move_and_slide()
