extends Node


# UI
signal toggle_screen(id:StringName, display:bool)
signal blink_portrait(is_scientist:bool)
signal update_hp(data:EntityData)
signal play_dino_attack_animation
signal dino_run_away

# SCENE MANAGER
signal load_scene(id:StringName, disply_loading:bool, extra_time:bool)

# GAME MANAGER
signal toggle_pause(value:bool)
signal request_scientist_data
signal return_scientist_data(scientists:Array[ScientistData], active:int)

# COMBAT MANAGER
signal enter_combat(dino_datas:Array[DinoData])
signal request_dino_data
signal return_dino_data(dino_datas:Array[DinoData])
signal display_combat_log(text:String)
signal display_combat_menu
signal start_combat
signal combat_log_awaiting
signal combat_log_continues
signal select_combat_action(action:StringName)
