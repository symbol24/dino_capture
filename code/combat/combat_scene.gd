class_name CombatScene extends Node2D



func _ready() -> void:
	Signals.toggle_screen.emit(&"combat_ui", true)
