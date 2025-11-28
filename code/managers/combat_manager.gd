class_name CombatManager extends Node


const RUNAWAY_CHECK := 0.5
const DINO_RUNAWAY := "%s has run away!"
const DINO_FAILED_RUNAWAY := "%s is unable to run away."
const DINO_ATTACK := "%s scares the scientist for %s."
const DINO_SUPER := " Its VERY scary."
const DINO_NOT := " Its NOT very scary."
const SCIENTIST_ATTACK := "%s distracts the dino for %s."
const SCIENTIST_SUPER := " Its VERY distracting."
const SCIENTIST_NOT := " Its NOT very distracting."
const SUPER_MULT := 1.5
const NOT_MULT := 0.5


var dinos:Array[DinoData]
var active := 0
var active_dino:DinoData:
	get:
		return dinos[active]
var _game_manager:GameManager = null:
	get:
		if _game_manager == null: _game_manager = get_tree().get_first_node_in_group(&"game_manager")
		return _game_manager
var _current_round := -1
var _previous_round := -1
var _dino_goes_first := false
var _round_log:Array[Dictionary] = []


func _ready() -> void:
	add_to_group(&"combat_manager")
	name = &"CombatManager"
	process_mode = PROCESS_MODE_PAUSABLE
	Signals.enter_combat.connect(_enter_combat)
	Signals.start_combat.connect(_start_combat)
	Signals.select_combat_action.connect(_receive_action)


func _enter_combat(dino_datas:Array[DinoData]) -> void:
	dinos = dino_datas.duplicate(true)
	Signals.request_scientist_data.emit()
	Signals.toggle_screen.emit(&"combat_ui", true)


func _start_combat() -> void:
	_current_round = -1
	_start_next_round()


func _start_next_round() -> void:
	_previous_round = _current_round
	_current_round += 1


func _receive_action(action:StringName) -> void:
	if _game_manager.active_scientist.speed <= active_dino.speed:
		Signals.display_combat_log.emit(_apply_dino_action())
	else:
		var _scientist_action = _apply_scientist_action(action)



func _apply_scientist_action(action:StringName) -> Dictionary:
	var result := {}
	match action:
		&"capture":
			pass # Capture
		&"run_away":
			pass # Run away
		_:
			var damage = _get_damage(_game_manager.active_scientist, active_dino)
	
	return result



func _apply_dino_action() -> String:
	var result := DINO_ATTACK
	var damage := {}
	match active_dino.get_action():
		&"run_away":
			var success := randf() <= RUNAWAY_CHECK + (active_dino.speed / _game_manager.active_scientist.speed)
			if success:
				result = DINO_RUNAWAY % active_dino.display_name
				Signals.dino_run_away.emit()
			else:
				result = DINO_FAILED_RUNAWAY % active_dino.display_name
		_:
			damage = _get_damage(active_dino, _game_manager.active_scientist)
			_game_manager.active_scientist.update_hp(-damage[&"damage"])
			match damage[&"effective"]:
				&"super":
					result += DINO_SUPER
				&"not":
					result += DINO_NOT
				_:
					pass
			result = result % [active_dino.display_name, damage[&"damage"]]
			Signals.play_dino_attack_animation.emit()

	return result


func _get_damage(attacker:EntityData, defender:EntityData) -> Dictionary:
	var result := {
		&"damage":0,
		&"effective":&"normal"
	}
	
	match attacker.type:
		EntityData.Entity_Type.MOVEMENT:
			if defender.type == EntityData.Entity_Type.SOUND:
				result[&"effective"] = &"super"
			elif defender.type == EntityData.Entity_Type.SMELL:
				result[&"effective"] = &"not"
		EntityData.Entity_Type.SOUND:
			if defender.type == EntityData.Entity_Type.SMELL:
				result[&"effective"] = &"super"
			elif defender.type == EntityData.Entity_Type.MOVEMENT:
				result[&"effective"] = &"not"
		_:
			if defender.type == EntityData.Entity_Type.MOVEMENT:
				result[&"effective"] = &"super"
			elif defender.type == EntityData.Entity_Type.SOUND:
				result[&"effective"] = &"not"
	
	match result[&"effective"]:
		&"super":
			result[&"damage"] = (attacker.attack_power * SUPER_MULT) - defender.armor
		&"not":
			result[&"damage"] = (attacker.attack_power * NOT_MULT) - defender.armor
		_:
			result[&"damage"] = attacker.attack_power - defender.armor

	return result
