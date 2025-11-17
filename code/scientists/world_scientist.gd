class_name WorldScientist extends CharacterBody2D


const SPEED := 40.0
const ACCELERATION := 200.0
const FRICTION := 300.0


@export var debug_data:ScientistData

var data:ScientistData
var direction:Vector2

var _input:InputController
var _detected := false


func _ready() -> void:
	setup_world_character()


func _process(delta: float) -> void:
	if not _detected:
		velocity = _move(delta)
		velocity.limit_length(1.0)
		move_and_slide()


func setup_world_character(new_data:ScientistData = debug_data) -> void:
	assert(debug_data != null, "Someone forgot the debug data for the scientist!")
	data = new_data.duplicate()
	_input = WorldPlayerController.new(&"world_player")
	add_child(_input)
	_input.register()
	enter_world()


func move(_direction:Vector2) -> void:
	direction = _direction


func detected() -> void:
	_detected = true
	velocity = Vector2.ZERO


func enter_world() -> void:
	_input.activate()
	_detected = false


func _move(delta:float) -> Vector2:
	if direction == Vector2.ZERO:
		return velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	else:
		var x:float = move_toward(velocity.x, direction.x * SPEED, delta * ACCELERATION)
		var y:float = move_toward(velocity.y, direction.y * SPEED, delta * ACCELERATION)
		return Vector2(x, y)
