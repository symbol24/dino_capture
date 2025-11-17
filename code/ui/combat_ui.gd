class_name CombatUi extends RiDControl


const IN_TIME := 0.4
const OUT_TIME := 0.3
const CHAR_TIME := 0.08
const ARRIVAL_TEXT := "A surprised %s has appeared!"
const BLINK_WAIT := 0.6
const INPUT_DELAY := 0.2


var dinos:Array[DinoData]
var scientists:Array[ScientistData]
var input_controller:CombatInputController
var _log:Array[String] = []
var _writing := false
var _blink := false
var _awaiting_input := false
var _skip_text := false
var _input_delay := false

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


func _ready() -> void:
	Signals.return_dino_data.connect(_setup_dino)
	Signals.return_scientist_data.connect(_setup_scientist)
	Signals.display_combat_log.connect(_add_text_to_log)
	modulate = Color.TRANSPARENT
	input_controller = CombatInputController.new(&"combat_input_controller")
	add_child(input_controller)
	input_controller.register()


func toggle_rid_control(_id := &"", display := false) -> void:
	if _id == id:
		if display:
			input_controller.activate()
			_get_datas()
			show()
			_intro()
		else:
			await _outro()
			hide()


func press_any_button() -> void:
	if not _input_delay:
		_input_delay = true
		if not _writing:
			if _awaiting_input:
				_stop_blinking()
				_awaiting_input = false
				if not _log.is_empty():
					_display_log_text()
		else:
			if not _skip_text:
				_skip_text = true

		get_tree().create_timer(INPUT_DELAY).timeout.connect(_reset_input_delay)


func _get_datas() -> void:
	Signals.request_dino_data.emit()
	Signals.request_scientist_data.emit()


func _setup_dino(_dinos:Array[DinoData]) -> void:
	assert(not _dinos.is_empty(), "No dinos received by combat ui, shutting down.")
	dinos = _dinos
	dino_name.text = dinos[0].display_name
	if dinos[0].sprite != null : dino_portrait.texture = dinos[0].sprite
	dino_hp_bar.value = dinos[0].max_hp / dinos[0].current_hp
	dino_hp_label.text = str(dinos[0].current_hp) + "/" + str(dinos[0].max_hp)


func _setup_scientist(_scientists:Array[ScientistData]) -> void:
	assert(not _scientists.is_empty(), "No Scientist datas. Shutting Down.")
	scientists = _scientists
	scientist_name.text = scientists[0].display_name
	if scientists[0].sprite != null: scientist_portrait.texture = scientists[0].sprite
	scientist_hp_bar.value = scientists[0].current_hp / scientists[0].max_hp
	scientist_hp_label.text = str(scientists[0].current_hp) + "/" + str(scientists[0].max_hp)


func _intro() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, IN_TIME)
	await tween.finished
	_log.append(ARRIVAL_TEXT % dinos[0].display_name)
	_display_log_text()
	_test_logs()


func _add_text_to_log(value:String) -> void:
	_log.append(value)


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


func _test_logs() -> void:
	_add_text_to_log("Test line 1")
	_add_text_to_log("Test line 2")
	_add_text_to_log("Test line 3 but longer")
	_add_text_to_log("Test line where I only continue talking for a few words but realize its pretty long.")


func _reset_input_delay() -> void:
	_input_delay = false
