extends CanvasLayer

@onready var margin_container: MarginContainer = $Control/MarginContainer
@onready var pause_menu: MarginContainer = $Control/PauseMenu
@onready var button_select: NinePatchRect = $Control/ButtonSelect
@onready var resume_button: TextureButton = $Control/PauseMenu/ListContainer/ButtonContainer/ResumeButton
@onready var button_container: VBoxContainer = $Control/PauseMenu/ListContainer/ButtonContainer
@onready var pause_bg: TextureRect = $Control/PauseBG

@onready var screen: ColorRect = $Screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen.visible = true;
	
	margin_container.visible = true;
	pause_menu.visible = false;
	button_select.visible = false;
	pause_bg.visible = false;
	
	var buttons := button_container.get_children();
	for i in buttons.size():
		var current_button = buttons.get(i);
		# Set Top Neighbor
		if i > 0:
			var prev_button = buttons.get(i-1);
			# Use get_path_to() to get the correct relative NodePath
			current_button.focus_neighbor_top = current_button.get_path_to(prev_button)
		# Set Bottom Neighbor
		if i < buttons.size() - 1:
			var next_button = buttons.get(i+1);
			current_button.focus_neighbor_bottom = current_button.get_path_to(next_button)
		# First button's top neighbor is the last button
		if i == 0:
			current_button.focus_neighbor_top = current_button.get_path_to(buttons.get(buttons.size()-1));
		# Last button's bottom neighbor is the first button
		if i == buttons.size() - 1:
			current_button.focus_neighbor_bottom = current_button.get_path_to(buttons.get(0));


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if get_tree().paused:
		if !pause_menu.visible:
			margin_container.visible = false;
			pause_menu.visible = true;
			button_select.visible = true;
			pause_bg.visible = true;
			resume_button.grab_focus();
			
		var focusNode = get_viewport().gui_get_focus_owner();
		var offset = Vector2(8.0, 8.0);
		button_select.size = focusNode.size+offset;
		button_select.position = focusNode.global_position-offset*.5;
	else:
		margin_container.visible = true;
		pause_menu.visible = false;
		button_select.visible = false;
		pause_bg.visible = false;

func _on_resume_button_pressed() -> void:
	get_tree().paused = false;

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn");
