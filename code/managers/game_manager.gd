class_name GameManager extends Node


const DEBUGSCIENTISTS:Array[ScientistData] = [preload("uid://p5bfe07co3xk")]


var scientists:Array[ScientistData] = []:
	get:
		if scientists.is_empty(): return DEBUGSCIENTISTS
		return scientists
var active_scientist:ScientistData:
	get:
		return scientists[_active]
var _active := 0


func _ready() -> void:
	add_to_group(&"game_manager")
	name = &"GameManager"
	process_mode = PROCESS_MODE_ALWAYS
