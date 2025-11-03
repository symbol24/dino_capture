extends Node


# UI
signal toggle_screen(id:StringName, display:bool)


# SCENE MANAGER
signal load_scene(id:StringName, disply_loading:bool, extra_time:bool)


# GAME MANAGER
signal toggle_pause(value:bool)
