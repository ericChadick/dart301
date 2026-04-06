extends Node3D


var flashTimer := 0.0;

@onready var _2c_r: MeshInstance3D = $"Armature/Skeleton3D/2c_r/2c_r"
@onready var _3c_r: MeshInstance3D = $"Armature/Skeleton3D/3c_r/3c_r"
@onready var _2c_l: MeshInstance3D = $"Armature/Skeleton3D/2c_l/2c_l"
@onready var _3c_l: MeshInstance3D = $"Armature/Skeleton3D/3c_l/3c_l"

@onready var connect_area: Area3D = $Armature/Skeleton3D/rib2/ConnectArea
@onready var connect_point: Marker3D = $Armature/Skeleton3D/rib2/ConnectPoint

var partsBreak : Array[Node3D];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	partsBreak.append(_3c_l);
	partsBreak.append(_3c_r);
	partsBreak.append(_2c_l);
	partsBreak.append(_2c_r);
	
	#apply_material_to_children(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

func apply_material_to_children(root_node: Node, mat:Material):
	var stack = [root_node]
	while stack.size() > 0:
		var node = stack.pop_back()
		
		# Apply to MeshInstance3D nodes
		if node is MeshInstance3D:
			node.get_active_material(0).next_pass = mat;
			
		# Continue searching children
		for child in node.get_children():
			stack.append(child)
