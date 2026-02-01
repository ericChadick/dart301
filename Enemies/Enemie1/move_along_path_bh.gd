@tool
extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var enemy := actor as Enemy
	if enemy == null or enemy.nav == null:
		return FAILURE

	if enemy.nav.is_navigation_finished():
		enemy.move_direction = Vector3.ZERO
		return SUCCESS

	var next := enemy.nav.get_next_path_position()
	var dir := (next - enemy.global_position)
	dir.y = 0
	if dir.length() < 0.01:
		enemy.move_direction = Vector3.ZERO
		return RUNNING

	enemy.move_direction = dir.normalized()
	return RUNNING
