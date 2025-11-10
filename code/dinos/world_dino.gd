class_name WorldDino extends Area2D


const TIME_TO_SCIENTIST := 0.75


@export var is_horizontal := false
@export var data:DinoData
var _target_pos:Vector2
var _tiggered := false
var _scientist:WorldScientist

@onready var detection_collider: CollisionShape2D = %detection_collider


func _ready() -> void:
	body_entered.connect(_body_entered)


func _body_entered(_body) -> void:
	if _body is WorldScientist and not _tiggered:
		_body.detected()
		_scientist = _body
		_detected_scientist()


func _detected_scientist() -> void:
	var x := 0.0
	var y := 0.0
	if is_horizontal:
			x = _scientist.global_position.x
			y = global_position.y
	else:
			x = global_position.x
			y = _scientist.global_position.y

	_target_pos = Vector2(x, y)
	_tiggered = true
	_move_to_scientist()


func _move_to_scientist() -> void:
	var tween := create_tween()
	tween.finished.connect(_scientist.enter_combat)
	tween.tween_property(self, "global_position", _target_pos, TIME_TO_SCIENTIST)
