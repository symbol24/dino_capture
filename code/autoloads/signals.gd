extends Node


# UI
signal toggle_screen(id:StringName, display:bool)

# SCENE MANAGER
signal load_scene(id:StringName, disply_loading:bool, extra_time:bool)

# GAME MANAGER
signal toggle_pause(value:bool)
signal request_scientist_data
signal return_scientist_data(scientists:Array[ScientistData])

# COMBAT MANAGER
signal enter_combat(dino_datas:Array[DinoData])
signal request_dino_data
signal return_dino_data(dino_datas:Array[DinoData])
signal display_combat_log(text:String, wait:bool)
