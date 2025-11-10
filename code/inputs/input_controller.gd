class_name InputController extends Node


var id:StringName

var _active := false
var _manager:InputManager = null:
	get:
		if _manager == null: _manager = get_tree().get_first_node_in_group(&"input_manager")
		return _manager


func _init(_id:StringName) -> void:
	id = _id


func _ready() -> void:
	_manager.input_changed.connect(_input_changed)


func process_input(_delta: float) -> void:
	if _active: # Do something
		pass


func register() -> void:
	_manager.register_input(self)


func deregister() -> void:
	_manager.deregister_input(self)


func activate() -> void:
	_manager.activate_input(self)


func _input_changed(input:InputController) -> void:
	if input != self:
		_active = false
	else:
		_active = true
