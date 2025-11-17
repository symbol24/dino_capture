class_name CombatManager extends Node


var dinos:Array[DinoData]


func _ready() -> void:
	name = &"CombatManager"
	process_mode = PROCESS_MODE_PAUSABLE
	Signals.enter_combat.connect(_enter_combat)
	Signals.request_dino_data.connect(_return_dinos)


func _enter_combat(dino_datas:Array[DinoData]) -> void:
	dinos = dino_datas.duplicate(true)
	Signals.toggle_screen.emit(&"combat_ui", true)


func _return_dinos() -> void:
	Signals.return_dino_data.emit(dinos)
