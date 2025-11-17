class_name EntityData extends Resource


enum Entity_Type {MOVEMENT, SOUND, SMELL}


@export var id := &""
@export var sprite:CompressedTexture2D

@export var display_name := ""
@export var description := ""

@export var _entity_type := Entity_Type.MOVEMENT

@export var _starting_hp := 1
@export var _starting_attack_power := 1
@export var _starting_armor := 0
@export var starting_speed := 1


var type:Entity_Type:
	get:
		return _entity_type
var current_hp := 1
var max_hp := 1
var attack_power :=  1
var armor := 0
var speed := 1


func setup_entity() -> void:
	max_hp = _starting_hp
	current_hp = max_hp
	attack_power = _starting_attack_power
	armor = _starting_armor
	speed = starting_speed


func update_hp(value:int) -> int:
	current_hp += value
	if current_hp < 0:
		current_hp = 0
	elif current_hp > max_hp:
		current_hp = max_hp
	return current_hp
