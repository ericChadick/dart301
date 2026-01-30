@tool
class_name CalculateMoveDirection_BH
extends ActionLeaf

enum MoveType {
	TO_TARGET = 0,
	AWAY_FROM_TARGET = 1,
}

@export var move_type: MoveType = MoveType.TO_TARGET

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var enemy_actor := actor as Node3D
	if enemy_actor == null:
		return FAILURE

	var target := get_tree().get_first_node_in_group("player") as Node3D
	if target == null:
		return FAILURE

	match move_type:
		MoveType.AWAY_FROM_TARGET:
			# direction from target -> enemy (so enemy moves away)
			enemy_actor.move_direction = target.global_position.direction_to(enemy_actor.global_position)
			return SUCCESS

		MoveType.TO_TARGET:
			# direction from enemy -> target
			enemy_actor.move_direction = enemy_actor.global_position.direction_to(target.global_position)
			return SUCCESS

	return FAILURE
