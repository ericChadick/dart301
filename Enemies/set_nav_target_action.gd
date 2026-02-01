@tool
extends ActionLeaf
class_name SetNavTarget_BH

enum TargetMode { PLAYER, LAST_SEEN }

@export var target_mode: TargetMode = TargetMode.PLAYER

func tick(actor: Node, blackboard: Blackboard) -> int:
	var enemy := actor as Enemy
	if enemy == null or enemy.nav == null:
		return FAILURE

	var pos: Vector3

	if target_mode == TargetMode.PLAYER:
		var player := enemy.get_tree().get_first_node_in_group("player") as Node3D
		if player == null:
			return FAILURE
		pos = player.global_position
	else:
		if not blackboard.get_value("has_last_seen", false):
			return FAILURE
		pos = blackboard.get_value("last_seen_pos", enemy.global_position)

	enemy.nav.target_position = pos
	return SUCCESS
