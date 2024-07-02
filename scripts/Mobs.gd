class_name Mobs

static func registry(node : PhysicsBody2D):
	var mobs = node.get_tree().get_nodes_in_group("mob");
	for mob in mobs:
		if mob != node:
			node.add_collision_exception_with(mob);