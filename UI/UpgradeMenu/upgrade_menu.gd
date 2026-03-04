extends CanvasLayer

@onready var currency: RichTextLabel = $Control/MarginContainer/Currency

@onready var cycle_sound: AudioStreamPlayer = $Audio/CycleSound
@onready var equip_sound: AudioStreamPlayer = $Audio/EquipSound
@onready var weapon_equip_sound: AudioStreamPlayer = $Audio/WeaponEquipSound

var hoverPrev : TextureButton;
var hoverCurrent : TextureButton;

var weaponSlotSelected : Control;

#focus nodes
var focusNode : Control;
var prevFocusNode : Control;
@onready var weapon_loadout_list: VBoxContainer = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/WeaponLoadoutList
@onready var weapon_loadout_slot: TextureButton = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/WeaponLoadoutList/WeaponLoadoutSlot
@onready var weapon_list: VBoxContainer = $Control/MarginContainer/SubmenuContainer/WeaponList
@onready var equip_parts_grid: GridContainer = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/EquipPartsGrid
@onready var go_button: TextureButton = $Control/MarginContainer/GoButton

@onready var part_info_panel: MarginContainer = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartInfoPanel
@onready var part_name: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartInfoPanel/VBoxContainer/PartName
@onready var part_description: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartInfoPanel/VBoxContainer/PartDescription
@onready var part_hover_preview: TextureRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerBaseIcon/PartHoverPreview
@onready var player_base_icon: TextureRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerBaseIcon

@onready var hardware_bar: ProgressBar = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/HardwareBar/HardwareBar
@onready var hardware_bar_preview: ProgressBar = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/HardwareBar/HardwareBar/HardwareBarPreview

var infoPanelHeight := 0.0;
var partHoverTime := 0.0;

#@onready var part_name: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartName
#@onready var part_description: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartDescription

const WEAPON_EMPTY = preload("uid://b70etp772do5m")

#debug toggles
@onready var battery_debug: TextureButton = $Control/MarginContainer/DebugToggles/BatteryDebug
@onready var cord_debug: HSlider = $Control/MarginContainer/DebugToggles/CordDebug

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hoverPrev = null;
	hoverCurrent = null;
	
	#set debug
	cord_debug.value = Global.cordLengthMin;
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	RenderingServer.set_default_clear_color(Color.BLACK);
	
	weapon_loadout_slot.grab_focus();
	
	#add weapon containers to weapon list based on number of weapons unlocked
	
	infoPanelHeight = part_info_panel.size.y;
	
	
	#set focus neighbors for weapon list
	var weaponsUnlocked := weapon_list.get_children();
	for i in weaponsUnlocked.size():
		var current_button = weaponsUnlocked.get(i);
		current_button.pressed.connect(onWeaponListPressed);
		current_button.focus_neighbor_right = current_button.get_path_to(weapon_loadout_slot);
		
		# Set Top Neighbor
		if i > 0:
			var prev_button = weaponsUnlocked[i-1]
			# Use get_path_to() to get the correct relative NodePath
			current_button.focus_neighbor_top = current_button.get_path_to(prev_button)
		# Set Bottom Neighbor
		if i < weaponsUnlocked.size() - 1:
			var next_button = weaponsUnlocked[i+1]
			current_button.focus_neighbor_bottom = current_button.get_path_to(next_button)
		# First button's top neighbor is the last button
		if i == 0 and weaponsUnlocked.size() > 1:
			var last_button = weaponsUnlocked[weaponsUnlocked.size() - 1]
			current_button.focus_neighbor_top = current_button.get_path_to(last_button)

		# Last button's bottom neighbor is the first button
		if i == weaponsUnlocked.size() - 1 and weaponsUnlocked.size() > 1:
			var first_button = weaponsUnlocked[0]
			current_button.focus_neighbor_bottom = current_button.get_path_to(first_button)
		#print(current_button);
		#print(current_button.focus_neighbor_top);
		#print(current_button.focus_neighbor_right);
		#print(current_button.focus_neighbor_bottom);
	
	#connect button pressed signal and function
	#set focus neighbors for weapon loadout buttons
	var weaponSlotsUnlocked := weapon_loadout_list.get_children();
	for i in weaponSlotsUnlocked.size():
		var current_button = weaponSlotsUnlocked.get(i);
		current_button.slotIndex = i+1;
		#print(current_button.slotIndex);
		current_button.pressed.connect(onWeaponLoadoutPressed);
		current_button.focus_neighbor_left = current_button.get_path_to(current_button);
		current_button.focus_neighbor_right = current_button.get_path_to(equip_parts_grid);
		
		# Set Top Neighbor
		if i > 0:
			var prev_button = weaponSlotsUnlocked[i-1]
			# Use get_path_to() to get the correct relative NodePath
			current_button.focus_neighbor_top = current_button.get_path_to(prev_button)
		# Set Bottom Neighbor
		if i < weaponSlotsUnlocked.size() - 1:
			var next_button = weaponSlotsUnlocked[i+1]
			current_button.focus_neighbor_bottom = current_button.get_path_to(next_button)
		# First button's top neighbor is the last button
		if i == 0 and weaponSlotsUnlocked.size() > 1:
			var last_button = weaponSlotsUnlocked[weaponSlotsUnlocked.size() - 1]
			#current_button.focus_neighbor_top = current_button.get_path_to(last_button)
			current_button.topRow = true;
			current_button.focus_neighbor_top = current_button.get_path_to(current_button);
		# Last button's bottom neighbor is the first button
		if i == weaponSlotsUnlocked.size() - 1:# and weaponSlotsUnlocked.size() > 1:
			#current_button.focus_neighbor_bottom = current_button.get_path_to(go_button);
			current_button.bottomRow = true;
			current_button.focus_neighbor_bottom = current_button.get_path_to(go_button);
	
	#set neighbors for equip parts grid
	var buttons = []
	for child in equip_parts_grid.get_children():
		if child is Control and child.focus_mode != Control.FOCUS_NONE:
			buttons.append(child)
	var columns = equip_parts_grid.columns;
	for i in range(buttons.size()):
		var current_button = buttons[i]
		current_button.pressed.connect(onEquipPartPressed);
		# Calculate neighbor indices
		var top_index = i - columns
		var bottom_index = i + columns
		var left_index = i - 1
		var right_index = i + 1
		# Assign neighbors, ensuring they are valid indices
		if top_index >= 0:
			current_button.focus_neighbor_top = buttons[top_index].get_path()
		else:
			current_button.topRow = true;
			current_button.focus_neighbor_top = current_button.get_path()
		if bottom_index < buttons.size():
			current_button.focus_neighbor_bottom = buttons[bottom_index].get_path()
		else:
			#print((i - (i % columns))/columns);
			if (i - (i % columns))/columns == columns-2: #bottom row
				current_button.focus_neighbor_bottom = current_button.get_path_to(go_button);
				current_button.bottomRow = true;
			else:
				current_button.focus_neighbor_bottom = buttons[buttons.size()-1].get_path()
			#
		# Handle left/right wrapping within the row if desired, otherwise Godot guesses
		if i % columns != 0: # Not in the first column
			current_button.focus_neighbor_left = buttons[left_index].get_path()
		else:
			current_button.focus_neighbor_left = current_button.get_path_to(weapon_loadout_slot)
		if (i + 1) % columns != 0 and right_index < buttons.size(): # Not in the last column
			current_button.focus_neighbor_right = buttons[right_index].get_path()
		else:
			current_button.focus_neighbor_right = current_button.get_path_to(current_button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currency.text = str(int(Global.currency));
	
	Global.cordLengthMin = cord_debug.value;
	
	prevFocusNode = focusNode;
	focusNode = get_viewport().gui_get_focus_owner();
	
	if go_button == focusNode and prevFocusNode != go_button:
		go_button.focus_neighbor_left = go_button.get_path_to(weapon_loadout_list.get_child(0));
		go_button.focus_neighbor_right = go_button.get_path_to(equip_parts_grid);
		
		if prevFocusNode != null and prevFocusNode.topRow:
			go_button.focus_neighbor_bottom = go_button.get_path_to(prevFocusNode);
			match (prevFocusNode.get_parent()):
				equip_parts_grid: go_button.focus_neighbor_top = go_button.get_path_to(equip_parts_grid.get_child(0));
				weapon_loadout_list: go_button.focus_neighbor_top = go_button.get_path_to(weapon_loadout_list.get_child(weapon_loadout_list.get_child_count()-1));
				
		if prevFocusNode != null and prevFocusNode.bottomRow:
			go_button.focus_neighbor_top = go_button.get_path_to(prevFocusNode);
			#match (prevFocusNode.get_parent()):
			#	equip_parts_grid: go_button.focus_neighbor_bottom = go_button.get_path_to(equip_parts_grid.get_child(0));
			#	weapon_loadout_list: go_button.focus_neighbor_bottom = go_button.get_path_to(weapon_loadout_list.get_child(0));
	
	#effect for already equipped weapons
	for i in weapon_list.get_child_count():
		if i > 0:
			for ii in weapon_loadout_list.get_child_count():
				weapon_list.get_child(i).modulate = Color.WHITE;
				if weapon_loadout_list.get_child(ii).weaponInd == weapon_list.get_child(i).weaponInd:
					weapon_list.get_child(i).modulate = Color.GRAY;
					break;
				
	
	if weapon_list == focusNode:
		var listStart = weapon_list.get_child(1);
		listStart.grab_focus();
	if equip_parts_grid == focusNode:
		var listStart = equip_parts_grid.get_child(0);
		listStart.grab_focus();
		#print(get_viewport().gui_get_focus_owner());
	
	#display info for selected part
	var equipBarIncrement = (1.0/Global.partSlots);
	var targValue := 0;
	for i in Global.partsEquipped:
		targValue += i.partCost;
	hardware_bar.value = float(targValue)/float(Global.partSlots);
	hardware_bar_preview.modulate = Color("a6a6a6");
	if focusNode.get_parent() == equip_parts_grid:
		var partSelect = focusNode.partInd;
		part_name.text = partSelect.partName;
		part_description.text = partSelect.partDescription;
		
		partHoverTime += delta;
		part_hover_preview.visible = true;
		part_hover_preview.modulate.a = round((sin(partHoverTime*10.0)+1.0)*.5);
		part_hover_preview.texture = partSelect.partHighlightTexture;
		part_hover_preview.position = partSelect.partMenuOffset;
		
		if focusNode.equipped_icon.visible:
			hardware_bar_preview.value = hardware_bar.value;
			hardware_bar.value -= partSelect.partCost*equipBarIncrement;
		else:
			hardware_bar_preview.value = hardware_bar.value + partSelect.partCost*equipBarIncrement;
			if targValue+partSelect.partCost > Global.partSlots:
				hardware_bar_preview.modulate = Color.RED;
		
		#part_info_panel.size.y = lerp(part_info_panel.size.y, infoPanelHeight, 10*delta);
	else:
		partHoverTime = 0.0;
		part_hover_preview.visible = false;
		part_name.text = "";
		part_description.text = "";
		
		hardware_bar_preview.value = 0.0;
		#part_info_panel.size.y = lerp(part_info_panel.size.y, 0.0, 10*delta);
		
	#hoverPrev = hoverCurrent;
	#var hoverButton = get_viewport().gui_get_hovered_control();
	#if hoverButton != null and hoverButton.get_class() == "TextureButton":
	#	hoverCurrent = hoverButton;
	#play cycle sound
	#if hoverCurrent != hoverPrev:
	#	cycle_sound.play();

func onWeaponLoadoutPressed() -> void:
	weaponSlotSelected = get_viewport().gui_get_focus_owner();
	if weaponSlotSelected.slotIndex <= Global.weaponSlots: #slot is unlocked
		weapon_list.grab_focus();
	
func onWeaponListPressed() -> void:
	var weaponSelect = focusNode.weaponInd;
	#focusNode.visible = false;
	
	#select top X option to unequip or go back
	if weaponSelect.weaponInd == Global.PlayerWeapon.FIST:
		weaponSlotSelected.grab_focus();
		weaponSelect = WEAPON_EMPTY;
	
	#select a new weapon
	if weaponSelect != weaponSlotSelected.weaponInd:
		weaponSlotSelected.grab_focus();
		var wPrev = weaponSlotSelected.weaponInd;
		weaponSlotSelected.weaponInd = weaponSelect;
		#selecting a weapon used by another slot will swap it out
		for i in weapon_loadout_list.get_child_count():
			if i != weaponSlotSelected.slotIndex-1:
				var lSlot = weapon_loadout_list.get_child(i);
				if weaponSlotSelected.weaponInd == lSlot.weaponInd:
					lSlot.weaponInd = WEAPON_EMPTY;
	else: 
		#select the same weapon from list to unequip
		weaponSlotSelected.grab_focus();
		weaponSlotSelected.weaponInd = WEAPON_EMPTY;
	
func onEquipPartPressed() -> void:
	var partSelect : equipPart;
	partSelect = focusNode.partInd;
	
	var equippedAlready := false;
	
	var equipAmnt := 0;
	for i in Global.partsEquipped:
		if i == partSelect:
			#print("ALREADY");
			equippedAlready = true;
		equipAmnt += i.partCost;
	
	if !equippedAlready:
		#print("Not");
		#has enough space, equip
		if equipAmnt+partSelect.partCost <= Global.partSlots:
			#add to equip array
			Global.partsEquipped.append(partSelect);
			focusNode.equipped_icon.visible = true;
			var partTex = TextureRect.new();#part_hover_preview.duplicate();
			player_base_icon.add_child(partTex);
			partTex.name = Global.PlayerParts.keys()[partSelect.partEnum].to_lower();
			partTex.texture = partSelect.partSelectedTexture;
			partTex.position = 	partSelect.partMenuOffset;
	else:
		focusNode.equipped_icon.visible = false;
		#remove from equip array
		var ind := Global.partsEquipped.find(partSelect);
		Global.partsEquipped.remove_at(ind);
		#find part texture on player to remove
		var partTexs := player_base_icon.get_children();
		for i in partTexs:
			if i.name == Global.PlayerParts.keys()[partSelect.partEnum].to_lower():
				i.queue_free();
		
		
func _on_go_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.mainScene);

func _on_battery_debug_pressed() -> void:
	Global.batteryDecreaseDebug = !Global.batteryDecreaseDebug;
	if Global.batteryDecreaseDebug:
		battery_debug.modulate = Color.YELLOW;
	else:
		battery_debug.modulate = Color.WHITE;
