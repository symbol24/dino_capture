class_name Ui extends CanvasLayer


const SCENES := preload("uid://b85a1hq3nnkbs")


var _rids:Array[RiDControl] = []


func _ready() -> void:
	name = &"UiCanvas"
	Signals.toggle_screen.connect(_toggle_rid)


func _toggle_rid(id:StringName, display:bool) -> void:
	var to_toggle := _get_rid(id)
	to_toggle.toggle_rid_control(id, display)


func _get_rid(_id:StringName) -> RiDControl:
	if _id == &"": return null
	var found:RiDControl = null
	for each in _rids:
		if each.id == _id:
			found = each
			break
	
	if found == null:
		var to_load := SCENES.controls[_id]
		found = load(to_load).instantiate()
		add_child(found)

	return found
