class_name Boot extends CanvasLayer


func _ready() -> void:
	await _load_managers()
	Signals.load_scene.emit(&"world_scene", false, false)
	queue_free()


func _load_managers() -> void:
	var im := InputManager.new()
	get_tree().root.add_child.call_deferred(im)
	if not im.is_node_ready(): await im.ready
	var sm := SceneManager.new()
	get_tree().root.add_child.call_deferred(sm)
	if not sm.is_node_ready(): await sm.ready
	var gm := GameManager.new()
	get_tree().root.add_child.call_deferred(gm)
	if not gm.is_node_ready(): await gm.ready
	var cm := CombatManager.new()
	get_tree().root.add_child.call_deferred(cm)
	if not cm.is_node_ready(): await cm.ready
	var ui := Ui.new()
	get_tree().root.add_child.call_deferred(ui)
	if not ui.is_node_ready(): await ui.ready
