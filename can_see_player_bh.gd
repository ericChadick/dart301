@tool
extends con
class_name CanSeePlayer_BH


@export var vision_range: float = 25.0
@export var fov_degrees: float = 90.0
@export var collision_mask: int = 1

func tick(actor: Node, blackboard: Blackboard) -> int:
	var enemy := actor as Enemy
	if enemy == null:
		return FAILURE

	var player := enemy.get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return FAILURE

	var from := enemy.global_position + Vector3.UP * enemy.eye_height
	var to := player.global_position + Vector3.UP * 1.2

	if from.distance_to(to) > vision_range:
		return FAILURE

	var to_player_dir := (to - from).normalized()
	var forward := -enemy.global_transform.basis.z.normalized()
	var cos_half_fov := cos(deg_to_rad(fov_degrees * 0.5))
	if forward.dot(to_player_dir) < cos_half_fov:
		return FAILURE

	var space := enemy.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	query.exclude = [enemy]

	var hit := space.intersect_ray(query)
	if hit.size() > 0:
		var c: Object = hit["collider"]
		if not (c is Node) or not (c as Node).is_in_group("player"):
			return FAILURE

	blackboard.set_value("last_seen_pos", player.global_position)
	blackboard.set_value("has_last_seen", true)
	return SUCCESS
