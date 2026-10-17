extends CharacterBody3D

@export var move_speed := 5.0
@export var mouse_sensitivity := 0.003
var health := 100.0
var yaw := 0.0
var pitch := -0.18
var mobile_move := Vector2.ZERO
var mobile_look := Vector2.ZERO
var camera_pivot: Node3D
var camera: Camera3D

func _ready() -> void:
	add_to_group("player")
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	var body_mesh := MeshInstance3D.new()
	body_mesh.mesh = capsule
	body_mesh.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.42, 0.75)
	body_mesh.material_override = material
	add_child(body_mesh)
	var shape := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.42
	capsule_shape.height = 1.8
	shape.shape = capsule_shape
	shape.position.y = 0.9
	add_child(shape)
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.45
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.1, 5.2)
	camera.current = true
	camera_pivot.add_child(camera)
	camera.look_at(Vector3(0, 0.8, 0))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -0.8, 0.35)
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if mobile_look.length() > 0.0:
		yaw -= mobile_look.x * delta * 2.4
		pitch = clamp(pitch - mobile_look.y * delta * 1.8, -0.8, 0.35)
	camera_pivot.rotation = Vector3(pitch, yaw, 0)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_dir += mobile_move
	input_dir = input_dir.limit_length()
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var direction := (right * input_dir.x + forward * -input_dir.y).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = -0.1
	move_and_slide()
	rotation.y = yaw
