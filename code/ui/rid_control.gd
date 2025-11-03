class_name RiDControl extends Control


@export var id := &""


func toggle_rid_control(_id := &"", display := false) -> void:
	if _id == id:
		if display:
			show()
		else:
			hide()
