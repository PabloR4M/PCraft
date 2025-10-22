extends Camera3D

# === MOVIMIENTO EN Z ===
@export var min_z: float = 6.5
@export var max_z: float = 10.0
@export var speed: float = 0.2

# === VARIABLES INTERNAS ===
var direction: int = 1
var moving: bool = false
var current_z: float = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_z = min_z
	global_transform.origin.z = current_z

func _process(delta):
	if not moving:
		return  # solo se mueve si está activo el movimiento

	current_z += direction * speed * delta
	if current_z >= max_z:
		current_z = max_z
		direction = -1
	elif current_z <= min_z:
		current_z = min_z
		direction = 1

	var pos = global_transform.origin
	pos.z = current_z
	global_transform.origin = pos

# === INICIAR MOVIMIENTO ===
func start_move():
	current_z = min_z
	global_transform.origin.z = current_z
	direction = 1
	moving = true

# === DETENER MOVIMIENTO ===
func stop_move():
	moving = false
