extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const ZOMBIE_SCRIPT = preload("res://scripts/zombie.gd")
var player: CharacterBody3D
var health_label: Label
var ammo_label: Label
var wave_label: Label
var message_label: Label
var ammo := 12
var reserve_ammo := 72
var kills := 0
var wave := 1
var fire_cooldown := 0.0
var spawn_timer := 0.0
var game_over := false
var touch_look_active := false
var look_last := Vector2.ZERO

func _ready() -> void:
	_make_world()
	player = CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	add_child(player)
	player.global_position = Vector3(0, 0.15, 0)
	_make_ui()
	for i in range(5):
		_spawn_zombie()

func _make_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.42, 0.46, 0.5)
	env.ambient_light_energy = 0.7
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -25, 0)
	sun.light_energy = 1.2
	add_child(sun)
	var floor_body := StaticBody3D.new()
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	floor_mesh.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.19, 0.27, 0.17)
	floor_mesh.material_override = grass
	floor_body.add_child(floor_mesh)
	var floor_col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(120, 0.2, 120)
	floor_col.shape = box
	floor_col.position.y = -0.1
	floor_body.add_child(floor_col)
	add_child(floor_body)
	for i in range(32):
		var prop := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = Vector3(randf_range(0.7, 2.0), randf_range(0.8, 3.0), randf_range(0.7, 2.0))
		prop.mesh = box_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.25, 0.25, 0.23)
		prop.material_override = mat
		prop.position = Vector3(randf_range(-22, 22), box_mesh.size.y / 2, randf_range(-22, 22))
		add_child(prop)

func _make_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.04, 0.04, 0.78)
	panel.position = Vector2(18, 18)
	panel.size = Vector2(340, 105)
	ui.add_child(panel)
	health_label = _label(ui, "HEALTH  100", Vector2(32, 25), 20)
	ammo_label = _label(ui, "AMMO  12 / 72", Vector2(32, 55), 18)
	wave_label = _label(ui, "WAVE 1  |  KILLS 0", Vector2(32, 82), 16)
	message_label = _label(ui, "SURVIVE THE DEAD ZONE", Vector2(0, 20), 24)
	message_label.anchor_left = 0.5
	message_label.anchor_right = 0.5
	message_label.position.x = -180
	message_label.size.x = 360
	var fire_btn := _button(ui, "FIRE", Vector2(-150, -140), Vector2(115, 90))
	fire_btn.anchor_left = 1
	fire_btn.anchor_right = 1
	fire_btn.anchor_top = 1
	fire_btn.anchor_bottom = 1
	fire_btn.button_down.connect(_fire)
	var reload_btn := _button(ui, "RELOAD", Vector2(-275, -115), Vector2(105, 65))
	reload_btn.anchor_left = 1
	reload_btn.anchor_right = 1
	reload_btn.anchor_top = 1
	reload_btn.anchor_bottom = 1
	reload_btn.pressed.connect(_reload)
	var move_btn := _button(ui, "▲", Vector2(30, -170), Vector2(85, 65))
	move_btn.anchor_top = 1
	move_btn.anchor_bottom = 1
	move_btn.button_down.connect(func(): player.mobile_move.y = -1.0)
	move_btn.button_up.connect(func(): player.mobile_move.y = 0.0)
	var left_btn := _button(ui, "◀", Vector2(5, -100), Vector2(65, 65))
	left_btn.anchor_top = 1
	left_btn.anchor_bottom = 1
	left_btn.button_down.connect(func(): player.mobile_move.x = -1.0)
	left_btn.button_up.connect(func(): player.mobile_move.x = 0.0)
	var right_btn := _button(ui, "▶", Vector2(100, -100), Vector2(65, 65))
	right_btn.anchor_top = 1
	right_btn.anchor_bottom = 1
	right_btn.button_down.connect(func(): player.mobile_move.x = 1.0)
	right_btn.button_up.connect(func(): player.mobile_move.x = 0.0)
	var back_btn := _button(ui, "▼", Vector2(30, -35), Vector2(85, 55))
	back_btn.anchor_top = 1
	back_btn.anchor_bottom = 1
	back_btn.button_down.connect(func(): player.mobile_move.y = 1.0)
	back_btn.button_up.connect(func(): player.mobile_move.y = 0.0)

func _label(parent: Node, value: String, pos: Vector2, font_size: int) -> Label:
	var item := Label.new()
	item.text = value
	item.position = pos
	item.add_theme_font_size_override("font_size", font_size)
	parent.add_child(item)
	return item

func _button(parent: Node, value: String, pos: Vector2, size: Vector2) -> Button:
	var item := Button.new()
	item.text = value
	item.position = pos
	item.size = size
	item.add_theme_font_size_override("font_size", 18)
	parent.add_child(item)
	return item

func _process(delta: float) -> void:
	if game_over:
		return
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	spawn_timer += delta
	if spawn_timer > maxf(2.0, 8.0 - float(wave) * 0.5) and get_tree().get_nodes_in_group("zombies").size() < 5 + wave:
		_spawn_zombie()
		spawn_timer = 0.0
	if get_tree().get_nodes_in_group("zombies").is_empty():
		wave += 1
		for i in range(mini(3 + wave, 12)):
			_spawn_zombie()
	if player.health <= 0:
		game_over = true
		message_label.text = "YOU DIED  •  TAP TO RESTART"
		message_label.mouse_filter = Control.MOUSE_FILTER_STOP
		message_label.gui_input.connect(func(event): if event is InputEventMouseButton and event.pressed: get_tree().reload_current_scene())
	health_label.text = "HEALTH  " + str(roundi(player.health))
	ammo_label.text = "AMMO  " + str(ammo) + " / " + str(reserve_ammo)
	wave_label.text = "WAVE " + str(wave) + "  |  KILLS " + str(kills)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_look_active = event.pressed and event.position.x > get_viewport().size.x * 0.42
		look_last = event.position
	elif event is InputEventScreenDrag and event.position.x > get_viewport().size.x * 0.42:
		player.mobile_look = event.relative
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_fire()

func _fire() -> void:
	if game_over or fire_cooldown > 0:
		return
	fire_cooldown = 0.28
	if ammo <= 0:
		message_label.text = "RELOAD!"
		return
	ammo -= 1
	var cam: Camera3D = player.camera
	var origin: Vector3 = cam.global_position
	var ray_end: Vector3 = origin + -cam.global_transform.basis.z * 55.0
	var query := PhysicsRayQueryParameters3D.create(origin, ray_end)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit and hit.collider and hit.collider.is_in_group("zombies"):
		hit.collider.health -= 30
		if hit.collider.health <= 0:
			hit.collider.queue_free()
			kills += 1
			if kills % 5 == 0:
				reserve_ammo += 12

func _reload() -> void:
	if ammo < 12 and reserve_ammo > 0:
		var needed := 12 - ammo
		var loaded := mini(needed, reserve_ammo)
		ammo += loaded
		reserve_ammo -= loaded

func _spawn_zombie() -> void:
	var zombie := CharacterBody3D.new()
	zombie.set_script(ZOMBIE_SCRIPT)
	var angle := randf() * TAU
	var distance := randf_range(10, 24)
	zombie.position = Vector3(cos(angle) * distance, 0.1, sin(angle) * distance)
	add_child(zombie)
