class_name Boot extends CanvasLayer


func _ready() -> void:
	await _load_managers()
	Signals.load_scene.emit(&"world_scene", false, false)


func _load_managers() -> void:
	var im := InputManager.new()
	add_child(im)
	if not im.is_node_ready(): await im.ready
	var ui := Ui.new()
	add_child(ui)
	if not ui.is_node_ready(): await ui.ready
	var scene_manager := SceneManager.new()
	add_child(scene_manager)
	if not scene_manager.is_node_ready(): await scene_manager.ready
