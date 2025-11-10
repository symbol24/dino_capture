class_name InputManager extends Node


signal input_changed(input:InputController)


var _active:InputController
var _input_pool:Array[InputController] = []


func _init() -> void:
	add_to_group(&"input_manager")


func _process(delta: float) -> void:
	if _active != null:
		_active.process_input(delta)


func register_input(input:InputController) -> void:
	if _input_pool.has(input): return
	_input_pool.append(input)


func deregister_input(input:InputController) -> void:
	_input_pool.erase(input)


func activate_input(input:InputController) -> void:
	assert(_input_pool.has(input), "Input %s not in input list. Need to register first." % input.id)
	_active = input
	input_changed.emit(_active)
