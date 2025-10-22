extends RigidBody3D
class_name Part

@export_enum("CPU", "RAM", "GPU", "SSD", "PSU", "MOTHERBOARD", "COOLER") var part_type: String = "CPU"

func _ready():
	# Agrega la pieza al grupo correspondiente para que los slots la detecten
	add_to_group(part_type.to_lower())
	print("Part creada: ", name, " tipo: ", part_type, " grupo: ", part_type.to_lower())

func is_being_held() -> bool:
	# Si el padre es "HandPosition", está siendo sostenida
	return get_parent() and get_parent().name == "HandPosition"
