class_name GameManager extends Node


const DEBUGSCIENTISTS:Array[ScientistData] = [preload("uid://p5bfe07co3xk")]


func _ready() -> void:
	name = &"GameManager"
	process_mode = PROCESS_MODE_ALWAYS
	Signals.request_scientist_data.connect(_return_scientist_data)
	


func _return_scientist_data() -> void:
	Signals.return_scientist_data.emit(DEBUGSCIENTISTS)
