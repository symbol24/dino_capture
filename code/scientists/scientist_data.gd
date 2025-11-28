class_name ScientistData extends EntityData


@export var starting_capture_power := 1.0

var capture_power:float

func setup_entity() -> void:
	super()
	capture_power = starting_capture_power
