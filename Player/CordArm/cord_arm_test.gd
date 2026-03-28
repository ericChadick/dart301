extends Node3D


@onready var cord_point: Marker3D = $PivotPoint/Armature/Skeleton3D/Bone_002/CordPoint
@onready var pivot_point: Marker3D = $PivotPoint

#clear inheritance, parent armature to pivot point after positioning
#change animation player root node to pivot point

const BOT_METAL = preload("uid://dan8p38whate8")

# Called when the nod1e enters the scene tree for the first time.
func _ready() -> void:
	apply_material_to_children(self, BOT_METAL);
	if Global.flipHands:
		scale.x *= -1;
		position.x *= -1;

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
