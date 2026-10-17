extends CharacterBody3D

var health := 60.0
var speed := 1.65
var attack_timer := 0.0
var target: Node3D

func _ready() -> void:
	add_to_group("zombies")
	target = get_tree().get_first_node_in_group("player")
	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.48
	capsule.height = 1.75
	mesh.mesh = capsule
	mesh.position.y = 0.88
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.27, 0.48, 0.22)
	mesh.material_override = mat
	add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.48
	shape.height = 1.75
	col.shape = shape
	col.position.y = 0.88
	add_child(col)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return
	attack_timer -= delta
	var to_player := target.global_position - global_position
	to_player.y = 0
	if to_player.length() > 1.25:
		var dir := to_player.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
	else:
		velocity.x = move_toward(velocity.x, 0, 8 * delta)
		velocity.z = move_toward(velocity.z, 0, 8 * delta)
		if attack_timer <= 0:
			target.health = maxf(0.0, target.health - 8.0)
			attack_timer = 1.0
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = -0.1
	move_and_slide()
