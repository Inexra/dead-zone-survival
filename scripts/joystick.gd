extends Control
## Simple optional touch stick visual/input helper. The prototype also exposes large touch buttons.
signal vector_changed(value: Vector2)
var active_touch := -1
var value := Vector2.ZERO
@export var radius := 72.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			active_touch = event.index
			_update_value(event.position)
		elif event.index == active_touch:
			active_touch = -1
			value = Vector2.ZERO
			vector_changed.emit(value)
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == active_touch:
		_update_value(event.position)

func _update_value(pos: Vector2) -> void:
	value = ((pos - size * 0.5) / radius).limit_length()
	vector_changed.emit(value)
	queue_redraw()

func _draw() -> void:
	draw_circle(size * 0.5, radius, Color(0.05, 0.05, 0.05, 0.35))
	draw_circle(size * 0.5 + value * radius, radius * 0.35, Color(0.8, 0.8, 0.8, 0.65))
