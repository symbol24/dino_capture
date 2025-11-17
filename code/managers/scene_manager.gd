class_name SceneManager extends Node


const SCENES := preload("uid://b85a1hq3nnkbs")
const EXTRA_LOAD_TIME := 1.0


var current_level:Node2D = null
var _to_load := &""
var _loading := false
var _load_complete := false
var _loading_status:ResourceLoader.ThreadLoadStatus
var _progress := []
var _extra_time := false


func _ready() -> void:
	name = &"SceneManager"
	process_mode = PROCESS_MODE_ALWAYS
	Signals.load_scene.connect(_load_scene)


func _process(_delta: float) -> void:
	if _loading:
		_loading_status = ResourceLoader.load_threaded_get_status(SCENES.list[_to_load], _progress)
		#print("loading ", _to_load , ": ", _progress[0]*100, "%")
		if _loading_status == ResourceLoader.THREAD_LOAD_LOADED:
			if not _load_complete:
				_load_complete = true
				_complete_load()


func _load_scene(id:StringName, disply_loading:bool, extra_time:bool) -> void:
	#print("Loading: ", id)
	if not SCENES.list.has(id):
		push_warning("'%s' is not in the list of scenes available to load!" % id)
		return

	_extra_time = extra_time
	Signals.toggle_screen.emit(&"loading_screen", disply_loading)
	_to_load = id
	_load_complete = false
	_loading_status = ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE
	Signals.toggle_pause.emit(true)

	if current_level != null:
		var temp = current_level
		current_level = null
		get_tree().root.remove_child(temp)
		temp.queue_free.call_deferred()

	ResourceLoader.load_threaded_request(SCENES.list[_to_load])
	_loading = true
	_loading_status = ResourceLoader.load_threaded_get_status(SCENES.list[_to_load], _progress)


func _complete_load() -> void:
	_loading = false
	current_level = ResourceLoader.load_threaded_get(SCENES.list[_to_load]).instantiate()
	get_tree().root.add_child.call_deferred(current_level)
	if not current_level.is_node_ready(): await current_level.ready
	if _extra_time: await get_tree().create_timer(EXTRA_LOAD_TIME).timeout
	Signals.toggle_pause.emit(false)
	#Signals.level_ready.emit()
	Signals.toggle_screen.emit(&"loading_screen", false)
	#if current_level is Level:
		#Signals.start_run.emit()
		#Signals.start_level.emit()
		#Signals.start_countdown.emit()


func _unload_level() -> void:
	current_level.queue_free.call_deferred()
