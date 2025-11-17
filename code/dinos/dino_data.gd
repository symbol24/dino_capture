class_name DinoData extends EntityData


@export var starting_capture_resist := 0

var current_capture_resist := 0
var max_capture_resist := 0


func setup_entity() -> void:
	super()
	max_capture_resist = starting_capture_resist
	current_capture_resist = max_capture_resist


func update_capture_resist(value:int) -> int:
	current_capture_resist += value
	if current_capture_resist < 0:
		current_capture_resist = 0
	elif current_capture_resist > max_capture_resist:
		current_capture_resist = max_capture_resist
	return current_capture_resist
