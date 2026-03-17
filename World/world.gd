@tool
extends Node

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

var SCROLLING_NOISE = preload("uid://cescn2nkwke18")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_viewport_container.set_process_input(true);
	Global.mainScene = get_tree().current_scene.scene_file_path;
	
func _input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		sub_viewport.push_input(event)
	
func _process(delta: float) -> void:
	pass;#SCROLLING_NOISE.offset.y += delta*50.0;
