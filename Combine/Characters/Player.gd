extends Node2D

var box_start = Vector2.ZERO
var box_end = Vector2.ZERO
var dragging_box = false
signal left_click
signal right_click


func _process(delta):
	get_input()
	if dragging_box:
		update_box()
	update()

func _draw():
	if not dragging_box:
		return
	var rect = Rect2(box_start, box_end - box_start)
	draw_rect(rect, Color(0.25, 1, 0.5, 0.5))
	draw_rect(rect, Color(1, 1, 1, 0.5), false, 30)
	draw_rect(rect, Color(0, 0, 0, 0.5), false, 10)

func update_box():
	box_end =  get_global_mouse_position()
	$Selector/CollisionShape2D.shape.extents = (box_end - box_start) / 2
	$Selector.global_position = box_start + ($Selector/CollisionShape2D.shape.extents)

func get_input():
	if Input.is_action_just_pressed("left_click"):
		dragging_box = true
		emit_signal("left_click")
		box_start = get_global_mouse_position()
		box_end = get_global_mouse_position()
	if Input.is_action_just_released("left_click"):
		dragging_box = false
		box_end = get_global_mouse_position()
	
	if Input.is_action_just_pressed("right_click"):
		emit_signal("right_click", get_global_mouse_position())


func _on_Selector_body_entered(body):
	if not dragging_box:
		return
	if "Sheep" in body.name:
		body.highlight()
