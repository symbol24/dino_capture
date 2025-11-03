class_name World extends Node2D


func _ready() -> void:
	Signals.toggle_screen.emit(&"world_ui", true)
