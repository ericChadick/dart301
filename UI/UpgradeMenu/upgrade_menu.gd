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


@onready var weapon_loadout_list: VBoxContainer = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/HBoxContainer/WeaponLoadoutList
@onready var weapon_loadout_slot: TextureButton = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/HBoxContainer/WeaponLoadoutList/WeaponLoadoutSlot
@onready var weapon_list: VBoxContainer = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/HBoxContainer/WeaponList
@onready var weapon_stat_list: VBoxContainer = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/VBoxContainer/HBoxContainer/WeaponStatList
@onready var weapon_description: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/VBoxContainer/HBoxContainer/Description

@onready var equip_parts_grid: GridContainer = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/EquipPartsGrid
@onready var go_button: TextureButton = $Control/MarginContainer/GoButton
@onready var exit_button: TextureButton = $Control/MarginContainer/ExitButton

@onready var part_info_panel: MarginContainer = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartInfoPanel
@onready var part_name: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartInfoPanel/VBoxContainer/PartName
@onready var part_description: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartInfoPanel/VBoxContainer/PartDescription
@onready var part_hover_preview: TextureRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerBaseIcon/PartHoverPreview
@onready var player_base_icon: TextureRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerBaseIcon

@onready var hardware_bar: ColorRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/HardwareBar
@onready var hardware_bar_preview: ColorRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/HardwareBar/Preview
@onready var hardware_bar_unequip: ColorRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/HardwareBar/Unequip
@onready var hardware_bar_over: ColorRect = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/HardwareBar/Over

#@onready var part_preview: MeshInstance3D = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartPreview/SubViewport/Preview
#@onready var weapon_preview: MeshInstance3D = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/VBoxContainer/WeaponPreview/SubViewport/Preview
@onready var weapon_sub_viewport: SubViewport = $Control/MarginContainer/SubmenuContainer/EquipWeaponsMenu/VBoxContainer/WeaponPreview/SubViewport
@onready var part_sub_viewport: SubViewport = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartPreview/SubViewport

@onready var player_sub_viewport: SubViewport = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerPreview/SubViewport
@onready var player_preview: SubViewportContainer = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerPreview
@onready var player_models: Node3D = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerPreview/SubViewport/PlayerModels
@onready var player_body: Node3D = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerPreview/SubViewport/PlayerModels/playerBody
#@onready var part_models: Node3D = $Control/MarginContainer/SubmenuContainer/PlayerEquipContainer/PlayerEquipVisual/PlayerPartsPreview/SubViewport/PartModels

@onready var grid_select: NinePatchRect = $GridSelect
@onready var weapon_connection_line: Line2D = $WeaponConnectionLine

var redC : Color = Color("e3715d");

var infoPanelHeight := 0.0;
var hoverTime := 0.0;

var buttonHoldTime := 0.0;

#add nodes with unlocked weapons and parts
const WEAPON_CONTAINER = preload("uid://ccjew7eqgtwfb");
const EQUIP_PART_SLOT = preload("uid://dolbdjtkaosjw");

#@onready var part_name: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartName
#@onready var part_description: RichTextLabel = $Control/MarginContainer/SubmenuContainer/EquipPartsMenu/PartDescription

const WEAPON_EMPTY = preload("uid://b70etp772do5m")

#material for weapon and part previews
const PREVIEW_MENU = preload("uid://pymetaslhxf")
const FLAT_COLOR = preload("uid://qv86qf4bbq3d")

const WIREFRAME = preload("uid://cuu8bpygtdto2")


#debug toggles
@onready var battery_debug: TextureButton = $Control/MarginContainer/DebugToggles/BatteryDebug
@onready var cord_debug: HSlider = $Control/MarginContainer/DebugToggles/CordDebug

var lastPartSelected : TextureButton;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hoverPrev = null;
	hoverCurrent = null;
	
	#set debug
	cord_debug.value = Global.cordLengthMin;
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	RenderingServer.set_default_clear_color(Color.BLACK);
	
	player_preview.grab_focus();
	weaponSlotSelected = weapon_loadout_slot;
	
	#add weapon containers to weapon list based on number of weapons unlocked
	infoPanelHeight = part_info_panel.size.y;
	
	hardware_bar.material.set("shader_parameter/count", Global.partSlots);
	hardware_bar_preview.material.set("shader_parameter/count", Global.partSlots);
	hardware_bar_unequip.material.set("shader_parameter/count", Global.partSlots);
	hardware_bar_over.material.set("shader_parameter/count", Global.partSlots);
	
	hardware_bar_preview.visible = false;
	hardware_bar_unequip.visible = false;
	hardware_bar_over.visible = false;
	
	#part_preview.visible = false;
	#weapon_preview.visible = false;
	
	var black = FLAT_COLOR.duplicate();
	black.set_shader_parameter("color", Vector3.ZERO);
	apply_material_to_children(player_body, black, 1);
	
	#add weapons containers
	for i in Global.weaponsUnlocked.size():
		var wi = Global.weaponsUnlocked[i];
		var wcontain = WEAPON_CONTAINER.instantiate();
		wcontain.weaponInd = wi;
		weapon_list.add_child(wcontain);
	
	#add equip part slots
	for i in equip_parts_grid.get_children():
		i.queue_free();
	for i in 16:
		var pcontain = EQUIP_PART_SLOT.instantiate();
		if i < Global.partsUnlocked.size():
			var pi = Global.partsUnlocked[i];
			pcontain.partInd = pi;
			pcontain.pressed.connect(onEquipPartPressed);
		else:
			pcontain.modulate = Color.GRAY;
			pcontain.get_child(0).visible = false; #equip icon 
		equip_parts_grid.add_child(pcontain);
		if i == equip_parts_grid.columns-1:
			lastPartSelected = pcontain;
	
	#set focus neighbors for weapon list
	var weaponsUnlocked := weapon_list.get_children();
	for i in weaponsUnlocked.size():
		var current_button = weaponsUnlocked.get(i);
		current_button.pressed.connect(onWeaponListPressed);
		current_button.focus_neighbor_left = current_button.get_path_to(weapon_loadout_slot);
		
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
		if Global.weaponsEquipped.size() >= i+1:
			current_button.weaponInd = Global.weaponsEquipped[i];
		
		current_button.slotIndex = i+1;
		#print(current_button.slotIndex);
		current_button.pressed.connect(onWeaponLoadoutPressed);
		current_button.focus_neighbor_left = current_button.get_path_to(player_preview);#equip_parts_grid
		current_button.focus_neighbor_right = current_button.get_path_to(current_button);
		
		# Set Top Neighbor
		if i > 0:
			var prev_button = weaponSlotsUnlocked[i-1]
			# Use get_path_to() to get the correct relative NodePath
			current_button.focus_neighbor_top = current_button.get_path_to(prev_button)
		# Set Bottom Neighbor
		if i < Global.weaponSlots - 1:
			var next_button = weaponSlotsUnlocked[i+1]
			current_button.focus_neighbor_bottom = current_button.get_path_to(next_button)
		# First button's top neighbor is the last button
		if i == 0 and Global.weaponSlots > 1:
			var last_button = weaponSlotsUnlocked[Global.weaponSlots]
			#current_button.focus_neighbor_top = current_button.get_path_to(last_button)
			current_button.topRow = true;
			current_button.focus_neighbor_top = current_button.get_path_to(current_button);
		# Last button's bottom neighbor is the first button
		if i == Global.weaponSlots - 1:# and weaponSlotsUnlocked.size() > 1:
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
			current_button.bottomRow = true;
			current_button.focus_neighbor_bottom = current_button.get_path_to(player_preview);#
			#print((i - (i % columns))/columns);
			#if (i - (i % columns))/columns == columns-2: #bottom row
			#	current_button.focus_neighbor_bottom = current_button.get_path_to(go_button);
			#	current_button.bottomRow = true;
			#else:
			#	current_button.focus_neighbor_bottom = buttons[buttons.size()-1].get_path()
			#
		# Handle left/right wrapping within the row if desired, otherwise Godot guesses
		if i % columns != 0: # Not in the first column
			current_button.focus_neighbor_left = buttons[left_index].get_path()
		else:
			current_button.focus_neighbor_left = current_button.get_path_to(current_button);
		if (i + 1) % columns != 0 and right_index < buttons.size(): # Not in the last column
			current_button.focus_neighbor_right = buttons[right_index].get_path()
		else:
			current_button.focus_neighbor_right = current_button.get_path_to(player_preview);#weapon_loadout_slot);
			
	
	#create weapon previews
	for i in weapon_list.get_child_count():
		if i > 0:
			var wp = weapon_list.get_child(i).weaponInd;
			var model = wp.weaponModelScene.instantiate();
			weapon_sub_viewport.add_child(model);
			model.position.z = -1.5;
			apply_material_to_children(model,WIREFRAME, 3);
			
	#create part previews
	for i in Global.partsUnlocked.size():
		var wp = Global.partsUnlocked[i];
		var model = wp.partMenuModel.instantiate();
		part_sub_viewport.add_child(model);
		model.position.z = -1.5;
		apply_material_to_children(model,WIREFRAME, 2);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currency.text = str(int(Global.currency));
	
	Global.cordLengthMin = cord_debug.value;
	
	var prev = focusNode;
	focusNode = get_viewport().gui_get_focus_owner();
	if prev != focusNode:
		prevFocusNode = prev;
		hoverTime = 0.0;
		buttonHoldTime = 0.0;
		
	hoverTime += delta;
	if Input.is_action_pressed("ui_accept"):
		buttonHoldTime += delta;
	else:
		buttonHoldTime = 0.0;
		
	#print(hoverTime);
		
	#part_preview.rotation.y += delta;
	#weapon_preview.rotation.y += delta;
	
	#rotate previews (skip camera node)
	for i in weapon_sub_viewport.get_child_count():
		if i > 0: 
			var ch = weapon_sub_viewport.get_child(i);
			ch.visible = false;
			ch.rotation.y += delta;
	for i in part_sub_viewport.get_child_count():
		if i > 0:
			var ch = part_sub_viewport.get_child(i);
			ch.visible = false;
			ch.rotation.y += delta;
			
	if go_button == focusNode and prevFocusNode != go_button:
		go_button.focus_neighbor_right = go_button.get_path_to(weapon_loadout_list.get_child(Global.weaponSlots-1));
		#go_button.focus_neighbor_left = go_button.get_path_to(exit_button);#equip_parts_grid);
		
		if prevFocusNode == player_preview:
			go_button.focus_neighbor_top = go_button.get_path_to(player_preview);
			go_button.focus_neighbor_bottom = go_button.get_path_to(go_button);
		#else:
			#if prevFocusNode != null:
				#if prevFocusNode.topRow:
					#go_button.focus_neighbor_bottom = go_button.get_path_to(go_button);#prevFocusNode);
					#match (prevFocusNode.get_parent()):
						#equip_parts_grid: go_button.focus_neighbor_top = go_button.get_path_to(equip_parts_grid.get_child(0));
						#weapon_loadout_list: go_button.focus_neighbor_top = go_button.get_path_to(weapon_loadout_list.get_child(weapon_loadout_list.get_child_count()-1));
					#
				#if prevFocusNode.bottomRow:
					#go_button.focus_neighbor_top = go_button.get_path_to(prevFocusNode);

	
	#effect for already equipped weapons
	for i in weapon_list.get_child_count():
		if i > 0:
			var ch = weapon_list.get_child(i);
			ch.weaponInd.calculateUpgradeCost();
			ch.upgrade_container.modulate = Color.GRAY;
			
			ch.upgrade_confirm.material.set("shader_parameter/alpha", .5);
			ch.upgrade_back.material.set("shader_parameter/alpha", .5);
			ch.upgrade_back_2.material.set("shader_parameter/alpha", .5);
			#modulate = Color.GRAY;
			
			ch.upgrade_back.rotation = 0.0;
			ch.upgrade_back_2.rotation = 0.0;
			
			ch.upgrade_cost.text = str(ch.weaponInd.newUpgradeCost);
			for ii in weapon_loadout_list.get_child_count():
				ch.modulate = Color.WHITE;
				if weapon_loadout_list.get_child(ii).weaponInd == ch.weaponInd:
					ch.modulate = Color.GRAY;
					break;
	
	#start at top of list or start at current weapon
	if weapon_list == focusNode:
		var wInd = weaponSlotSelected.weaponInd;
		print(wInd);
		for i in weapon_list.get_child_count():
			var ch = weapon_list.get_child(i);
			if wInd == WEAPON_EMPTY:
				if i == 1:
					ch.grab_focus();
					break;
			else:
				if ch.weaponInd == wInd:
					ch.grab_focus();
					break;
		
	if equip_parts_grid == focusNode:
		var listStart = lastPartSelected;
		listStart.grab_focus();
	if weapon_loadout_list == focusNode:
		weaponSlotSelected.grab_focus();
	
	#display info for selected part
	var equipBarIncrement = (1.0/Global.partSlots);
	var targValue := 0;
	for i in Global.partsEquipped:
		targValue += i.partCost;
	var barFill = float(targValue)/float(Global.partSlots) - .02;
	
	hardware_bar_preview.visible = false;
	hardware_bar_unequip.visible = false;
	hardware_bar_over.visible = false;
	
	grid_select.visible = false;
	
	if focusNode != player_preview:
		player_models.rotation.y += delta*.5;
	else:
		var input = Input.is_action_pressed("up");
		player_models.rotation.y += int(input)*delta*3.0;
		setGridSelect();
		
	#weapon_preview.visible = false;
	weapon_description.visible = false;
	for i in weapon_stat_list.get_child_count():
		var wsc = weapon_stat_list.get_child(i);
		wsc.weaponType = WEAPON_EMPTY;
		#wsc.visible = false;
	
	if focusNode.get_parent() == weapon_loadout_list:
		setGridSelect();
		
		var listPos = focusNode.get_index();
		if focusNode.weaponInd != WEAPON_EMPTY:
			weapon_sub_viewport.get_child(focusNode.slotIndex).visible = true;
			weapon_description.visible = true;
			
			var wp = focusNode.weaponInd;
			weapon_description.text = "[b]" + wp.weaponName + "[/b]" + " : " + wp.weaponDescription;
			#wp.calculateUpgradeCost();
			for i in weapon_stat_list.get_child_count():
				var wsc = weapon_stat_list.get_child(i);
				wsc.visible = true;
				wsc.weaponType = wp;
				wsc.canAfford = Global.currency >= wp.newUpgradeCost;
	
	weapon_connection_line.clear_points();
	if focusNode.get_parent() == weapon_list:
		var p1 = focusNode.global_position+Vector2(0.0, focusNode.size.y*.5);
		var p2 = weaponSlotSelected.global_position+Vector2(weaponSlotSelected.size.x, weaponSlotSelected.size.y*.5);
		weapon_connection_line.add_point(p1);
		weapon_connection_line.add_point(Vector2((p1.x+p2.x)*.5, p1.y));
		weapon_connection_line.add_point(p2);
		
		setGridSelect();
		
		var listPos = focusNode.get_index();
		if listPos > 0 and focusNode.weaponInd != WEAPON_EMPTY:
			#weapon_preview.visible = true;
			weapon_sub_viewport.get_child(listPos).visible = true;
			weapon_description.visible = true;
			
			if Global.currency >= focusNode.weaponInd.newUpgradeCost:
				focusNode.upgrade_container.modulate = Color.WHITE;
				focusNode.upgrade_container.modulate.a = round((sin(hoverTime*10.0)+1.0)*.5);
				
				var holdTimeMax := 3.0;
				var ratio = buttonHoldTime/holdTimeMax;
				focusNode.upgrade_confirm.material.set("shader_parameter/progress", ratio);
				focusNode.upgrade_bar.value = ratio;
				
				focusNode.upgrade_confirm.material.set("shader_parameter/alpha", 1.0);
				focusNode.upgrade_back.material.set("shader_parameter/alpha", 1.0);
				focusNode.upgrade_back_2.material.set("shader_parameter/alpha", 1.0);
				focusNode.upgrade_back.rotation = -buttonHoldTime*3.0;
				focusNode.upgrade_back_2.rotation = buttonHoldTime*1.5;
				
				if buttonHoldTime >= holdTimeMax:
					buttonHoldTime = 0.0;
					Global.currency -= focusNode.weaponInd.newUpgradeCost;
					focusNode.weaponInd.upgradeLevel += 1;
					
					focusNode.upgrade_confirm.material.set("shader_parameter/progress", 0.0);
					focusNode.upgrade_bar.value = 0.0;
					
					onWeaponListPressed(true);
					
			var wp = focusNode.weaponInd;
			weapon_description.text = "[b]" + wp.weaponName + "[/b]" + " : " + wp.weaponDescription;
			#wp.calculateUpgradeCost();
			for i in weapon_stat_list.get_child_count():
				var wsc = weapon_stat_list.get_child(i);
				wsc.visible = true;
				wsc.weaponType = wp;
				wsc.canAfford = Global.currency >= wp.newUpgradeCost;
	
		
		
	#part_preview.visible = false;
	if focusNode.get_parent() == equip_parts_grid:
		#part preview visiblity
		var listPos = focusNode.get_index();
		if listPos < Global.partsUnlocked.size():
			part_sub_viewport.get_child(listPos).visible = true;
		
		setGridSelect();
		#grid_select.visible = true;
		#grid_select.position = focusNode.global_position;
		#var sc = 1.0+round((sin(hoverTime*10.0)+1.0)*.5)*.1;
		#grid_select.scale = Vector2(sc, sc);
		
		lastPartSelected = focusNode;
		
		var partSelect = focusNode.partInd;
		part_name.text = partSelect.partName;
		part_description.text = partSelect.partDescription;
		
		part_hover_preview.visible = true;
		part_hover_preview.texture = partSelect.partHighlightTexture;
		part_hover_preview.position = partSelect.partMenuOffset;
		part_hover_preview.modulate = Color.WHITE;
		
		if focusNode.equipped_icon.visible:
			hardware_bar_unequip.visible = true;
			hardware_bar_unequip.material.set("shader_parameter/value", barFill);
			hardware_bar_unequip.material.set("shader_parameter/alpha", round((sin(hoverTime*10.0)+1.0)*.5));
			barFill -= partSelect.partCost*equipBarIncrement;
		else:
			if targValue+partSelect.partCost > Global.partSlots:
				part_hover_preview.modulate = redC;
				
				hardware_bar_over.visible = true;
				hardware_bar_over.material.set("shader_parameter/alpha", round((sin(hoverTime*10.0)+1.0)*.5));
				hardware_bar_over.material.set("shader_parameter/value", barFill + partSelect.partCost*equipBarIncrement);
			else:
				hardware_bar_preview.visible = true;
				hardware_bar_preview.material.set("shader_parameter/alpha", round((sin(hoverTime*10.0)+1.0)*.5));
				hardware_bar_preview.material.set("shader_parameter/value", barFill + partSelect.partCost*equipBarIncrement);
		
		hardware_bar.material.set("shader_parameter/value", barFill);
		#part_info_panel.size.y = lerp(part_info_panel.size.y, infoPanelHeight, 10*delta);
	else:
		part_hover_preview.visible = false;
		part_name.text = "";
		part_description.text = "";
		
		#hardware_bar_preview.value = 0.0;
		
		#part_info_panel.size.y = lerp(part_info_panel.size.y, 0.0, 10*delta);
	
	#hover over empty part slots effect
	#BINARY EFFECT
	for i in equip_parts_grid.get_child_count():
		if i >= Global.partsUnlocked.size():
			if focusNode == equip_parts_grid.get_child(i):
				var nameStr = "";
				var nameDesc = "";
				for b in 16:
					nameStr += str(int(randf() >= .5))
					nameDesc += str(int(randf() >= .5))
				part_name.text = nameStr;
				part_description.text = nameDesc;
	
	
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
	
func onWeaponListPressed(upgraded : bool = false) -> void:
	var weaponSelect = focusNode.weaponInd;
	#focusNode.visible = false;
	
	
	#select top X option to unequip or go back
	if weaponSelect.weaponInd == Global.PlayerWeapon.FIST:
		weaponSlotSelected.grab_focus();
		weaponSelect = WEAPON_EMPTY;
	else:
		focusNode.upgrade_confirm.material.set("shader_parameter/progress", 0.0);
		focusNode.upgrade_bar.value = 0.0;
	
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
		if !upgraded:
			#select the same weapon from list to unequip
			weaponSlotSelected.grab_focus();
			weaponSlotSelected.weaponInd = WEAPON_EMPTY;
	
func onEquipPartPressed() -> void:
	var partSelect : equipPart;
	partSelect = focusNode.partInd;
	
	var equippedAlready := false;
	
	var equipAmnt := 0;
	for i in Global.partsEquipped:
		equipAmnt += i.partCost;
		if i == partSelect:
			equippedAlready = true;
				
	#for i in Global.partsUnlocked:
	#	if partSelect == i:
	#		equippedAlready = true;
		
		#for p in Global.partsEquipped:
			#if slot.partInd == p:
				#equipAmnt += slot.partInd.partCost;
			#if partSelect
				#equippedAlready = true;
			#var e = equip_parts_grid.get_child(i);
			#if e == partSelect:
				#
			#equipAmnt += e.partCost;
	
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
			
			
			var p = partSelect.partMenuModel.instantiate();
			player_models.add_child(p);
			p.position = partSelect.partMenuPosition;
			p.rotation = partSelect.partMenuRotation;
			p.scale = partSelect.partMenuScale;
			apply_material_to_children(p, FLAT_COLOR, 4);
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
	#set weapons for run
	for i in weapon_loadout_list.get_child_count():
		var ind = weapon_loadout_list.get_child(i).weaponInd;
		Global.weaponsEquipped[i] = ind;
		
	get_tree().change_scene_to_file(Global.mainScene);

func _on_exit_button_pressed() -> void:
	#get_tree().quit();
	get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn");

func _on_battery_debug_pressed() -> void:
	Global.batteryDecreaseDebug = !Global.batteryDecreaseDebug;
	if Global.batteryDecreaseDebug:
		battery_debug.modulate = Color.YELLOW;
	else:
		battery_debug.modulate = Color.WHITE;

func setGridSelect():
	grid_select.visible = true;
	var s = round((sin(hoverTime*10.0)+1.0)*.5)*4.0;
	var offset = Vector2(8.0, 8.0);
	var stretch = Vector2(s, s);
	grid_select.size = focusNode.size+offset+stretch;
	grid_select.position = focusNode.global_position-offset*.5-stretch*.5;
		
func apply_material_to_children(root_node: Node, mat:Material, layer : int):
	var stack = [root_node]
	while stack.size() > 0:
		var node = stack.pop_back()
		
		# Apply to MeshInstance3D nodes
		if node is MeshInstance3D:
			#if mat != null:
			node.material_override = mat;
			node.set_layer_mask_value(1, false);
			node.set_layer_mask_value(layer, true);
			
		# Continue searching children
		for child in node.get_children():
			stack.append(child)
