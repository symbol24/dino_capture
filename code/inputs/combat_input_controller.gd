class_name CombatInputController extends InputController


var _combat_ui:CombatUi = null:
	get:
		if _combat_ui == null: _combat_ui = get_parent()
		return _combat_ui


func process_input(_delta: float) -> void:
	if _active:
		if Input.is_action_just_pressed(&"up"): _combat_ui.move_menu_selection(true)
		elif Input.is_action_just_pressed(&"down"): _combat_ui.move_menu_selection(false)
		elif Input.is_action_just_pressed(&"confirm"): _combat_ui.select_combat_option()
		
		if Input.is_anything_pressed(): _combat_ui.press_any_button()
			
