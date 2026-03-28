extends CanvasLayer

@onready var button_container: VBoxContainer = $Control/MarginContainer/ListContainer/ButtonContainer

@onready var start_button: TextureButton = $Control/MarginContainer/ListContainer/ButtonContainer/StartButton
@onready var options_button: TextureButton = $Control/MarginContainer/ListContainer/ButtonContainer/OptionsButton
@onready var exit_button: TextureButton = $Control/MarginContainer/ListContainer/ButtonContainer/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.grab_focus()
	
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
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit();

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://World/JunkHole/junk_hole.tscn");
