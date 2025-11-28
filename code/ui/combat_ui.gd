class_name CombatUi extends RiDControl


const IN_TIME := 0.4
const OUT_TIME := 0.3
const CHAR_TIME := 0.08
const ARRIVAL_TEXT := "A surprised %s has appeared!"
const BLINK_WAIT := 0.6
const INPUT_DELAY := 0.2
const FLASH_TIME := 0.2
const FLASH_COUNT := 3
const RUN_AWAY_TIME := 1.0


var _input_controller:CombatInputController
var _log:Array[String] = []
var _writing := false
var _blink := false
var _awaiting_input := false
var _skip_text := false
var _input_delay := false
var _menu_pos := 0
var _dino_ran_away := false
var _game_manager:GameManager = null:
	get:
		if _game_manager == null: _game_manager = get_tree().get_first_node_in_group(&"game_manager")
		return _game_manager
var _combat_manager:CombatManager = null:
	get:
		if _combat_manager == null: _combat_manager = get_tree().get_first_node_in_group(&"combat_manager")
		return _combat_manager

@onready var dino_name: Label = %dino_name
@onready var dino_portrait: TextureRect = %dino_portrait
@onready var dino_hp_bar: ProgressBar = %dino_hp_bar
@onready var dino_hp_label: Label = %dino_hp_label
@onready var scientist_name: Label = %scientist_name
@onready var scientist_hp_bar: ProgressBar = %scientist_hp_bar
@onready var scientist_portrait: TextureRect = %scientist_portrait
@onready var scientist_hp_label: Label = %scientist_hp_label
@onready var combat_log: RichTextLabel = %combat_log
@onready var continue_sprite: TextureRect = %continue_sprite
@onready var combat_menu: PanelContainer = %combat_menu
@onready var btn_icons:Array[TextureRect] = [%distract_icon, %capture_icon, %runaway_icon]


func _ready() -> void:
	Signals.return_dino_data.connect(_setup_dino)
	Signals.return_scientist_data.connect(_setup_scientist)
	Signals.display_combat_log.connect(_add_text_to_log)
	Signals.display_combat_menu.connect(_display_combat_menu)
	Signals.update_hp.connect(_update_hp)
	Signals.blink_portrait.connect(_blink_portrait)
	Signals.dino_run_away.connect(_dino_run_away)
	modulate = Color.TRANSPARENT
	_input_controller = CombatInputController.new(&"combat_input_controller")
	add_child(_input_controller)
	_input_controller.register()


func toggle_rid_control(_id := &"", display := false) -> void:
	if _id == id:
		if display:
			_input_controller.activate()
			_setup_dino()
			_setup_scientist()
			show()
			_intro()
		else:
			await _outro()
			hide()


func press_any_button() -> void:
	if combat_menu.visible: return
	if not _input_delay:
		_input_delay = true
		if not _writing:
			if _awaiting_input:
				_stop_blinking()
				_awaiting_input = false
				if not _log.is_empty():
					_display_log_text()
				else:
					if _dino_ran_away:
						toggle_rid_control(id, false)
						Signals.toggle_screen.emit(&"world_ui", true)
					else:
						_display_combat_menu()
		else:
			if not _skip_text:
				_skip_text = true

		get_tree().create_timer(INPUT_DELAY).timeout.connect(_reset_input_delay)


func move_menu_selection(is_up := false) -> void:
	if not _input_delay:
		if not _awaiting_input and combat_menu.visible:
			_menu_pos = _menu_pos - 1 if is_up else _menu_pos + 1
			if _menu_pos < 0: _menu_pos = btn_icons.size()-1
			elif _menu_pos >= btn_icons.size(): _menu_pos = 0
			_toggle_icons()

		get_tree().create_timer(INPUT_DELAY).timeout.connect(_reset_input_delay)


func select_combat_option() -> void:
	if combat_menu.visible and not _input_delay:
		var menu_option := &"attack"
		match _menu_pos:
			1:
				menu_option = &"capture"
			2:
				menu_option = &"run_away"
			_:
				menu_option = &"attack"
		Signals.select_combat_action.emit(menu_option)
		combat_menu.hide()
		get_tree().create_timer(INPUT_DELAY).timeout.connect(_reset_input_delay)


func _setup_dino() -> void:
	dino_name.text = _combat_manager.active_dino.display_name
	if _combat_manager.active_dino.sprite != null : dino_portrait.texture = _combat_manager.active_dino.sprite
	dino_hp_bar.value = _combat_manager.active_dino.max_hp / _combat_manager.active_dino.current_hp
	dino_hp_label.text = str(_combat_manager.active_dino.current_hp) + "/" + str(_combat_manager.active_dino.max_hp)
	_dino_ran_away = false


func _setup_scientist() -> void:
	scientist_name.text = _game_manager.active_scientist.display_name
	if _game_manager.active_scientist.sprite != null: scientist_portrait.texture = _game_manager.active_scientist.sprite
	scientist_hp_bar.value = _game_manager.active_scientist.current_hp / _game_manager.active_scientist.max_hp
	scientist_hp_label.text = str(_game_manager.active_scientist.current_hp) + "/" + str(_game_manager.active_scientist.max_hp)


func _intro() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, IN_TIME)
	await tween.finished
	_add_text_to_log(ARRIVAL_TEXT % _combat_manager.active_dino.display_name)
	Signals.start_combat.emit()


func _add_text_to_log(value:String) -> void:
	_log.append(value)
	if not _blink and not _awaiting_input: _display_log_text()


func _display_log_text() -> void:
	if _log.is_empty(): return
	_writing = true
	combat_log.text += "\n"
	var value:String = _log.pop_front()
	var x := 0
	while x < value.length():
		combat_log.text += value[x]
		var wait_time:float = CHAR_TIME/4 if _skip_text else CHAR_TIME
		await get_tree().create_timer(wait_time).timeout
		x += 1
	_skip_text = false
	_writing = false
	_awaiting_input = true
	_start_blinking()
	Signals.combat_log_awaiting.emit()


func _outro() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, OUT_TIME)
	await tween.finished


func _continue_blink() -> void:
	if _blink:
		continue_sprite.visible = !continue_sprite.visible
		await get_tree().create_timer(BLINK_WAIT).timeout
		_continue_blink()


func _start_blinking() -> void:
	_blink = true
	_continue_blink()


func _stop_blinking() -> void:
	_blink = false
	continue_sprite.hide()
	Signals.combat_log_continues.emit()


func _test_logs() -> void:
	_add_text_to_log("Test line 1")
	_add_text_to_log("Test line 2")
	_add_text_to_log("Test line 3 but longer")
	_add_text_to_log("Test line where I only continue talking for a few words but realize its pretty long.")


func _reset_input_delay() -> void:
	_input_delay = false


func _display_combat_menu() -> void:
	_menu_pos = 0
	combat_menu.show()


func _toggle_icons() -> void:
	for each in btn_icons:
		each.hide()
	
	btn_icons[_menu_pos].show()


func _blink_portrait(data:EntityData) -> void:
	var portrait := scientist_portrait if data is ScientistData else dino_portrait
	var tween := create_tween()
	for x in FLASH_COUNT:
		tween.tween_property(portrait, "modulate", Color.TRANSPARENT, FLASH_TIME)
		tween.tween_property(portrait, "modulate", Color.WHITE, FLASH_TIME)


func _update_hp(data:EntityData) -> void:
	if data is ScientistData:
		scientist_hp_bar.value = float(data.current_hp) / float(data.max_hp)
		scientist_hp_label.text = str(data.current_hp) + "/" + str(data.max_hp)
	else:
		dino_hp_bar.value = float(data.current_hp) / float(data.max_hp)
		dino_hp_label.text = str(data.current_hp) + "/" + str(data.max_hp)


func _dino_run_away() -> void:
	_dino_ran_away = true
	var tween := create_tween()
	tween.tween_property(dino_portrait, "modulate", Color.TRANSPARENT, RUN_AWAY_TIME)
