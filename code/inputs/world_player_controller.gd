class_name WorldPlayerController extends InputController


var _player:WorldScientist = null:
	get:
		if _player == null: _player = get_parent()
		return _player


func process_input(_delta: float) -> void:
	if _active:
		var direction:Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
		_player.move(direction)
