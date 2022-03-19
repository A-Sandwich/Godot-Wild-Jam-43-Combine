extends Node2D

var box_start = Vector2.ZERO
var box_end = Vector2.ZERO
var selection_id = -9223372036854775807
var dragging_box = false
signal left_click
signal right_click
signal merge_sheep
signal go_to_sheep
var selection = {}
var is_merging_sheep = false
var used_selection_ids = {}
var bounds = {}

func _ready():
	$"/root/GlobalState".connect("go_to_sheep", self, "_on_go_to_sheep")

func _process(delta):
	get_input()
	if dragging_box:
		update_box()
	update()
	if selection.keys().size() < 1:
		$HUD/Button.visible = false
	else:
		$HUD/Button.visible = true

func _draw():
	if get_tree().debug_collisions_hint:
		var bounds_rect = Rect2(bounds["topLeft"].x, bounds["topLeft"].y, abs(bounds["topLeft"].x) + bounds["bottomRight"].x, abs(bounds["topLeft"].y) + bounds["bottomRight"].y)
		draw_rect(bounds_rect, Color(1, 0, 0, 0.5), false, 30)
		draw_rect(bounds_rect, Color(1, 0, 0, 0.5), false, 10)

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
	if Input.is_action_just_pressed("left_click") and not is_merging_sheep:
		selection_id += 1
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
		selection[body.get_instance_id()] = body
		body.highlight()
		
func _on_Selector_body_exited(body):
	if not dragging_box:
		return
	if body.is_in_group("sheep"):
		body.unhighlight()
		selection.erase(body.get_instance_id())

func _on_Button_pressed():
	selection_id += 1
	var centroid = get_sheep_centroid()
	selection.clear()
	emit_signal("merge_sheep", centroid, selection_id)
	is_merging_sheep = false

func get_sheep_centroid():
	var valid_sheep = 0
	var x_sum = 0
	var y_sum = 0
	for key in selection.keys():
		var sheep = selection[key]
		if is_instance_valid(sheep):
			valid_sheep += 1
			x_sum += sheep.global_position.x
			y_sum += sheep.global_position.y
	if valid_sheep < 1:
		return Vector2.ZERO
	var centroid_x = (1.0/valid_sheep) * x_sum
	var centroid_y = (1.0/valid_sheep) * y_sum
	return Vector2(centroid_x, centroid_y)


func _on_Button_mouse_entered():
	is_merging_sheep = true


func _on_Button_mouse_exited():
	is_merging_sheep = false

func _on_merge_to_sheep(sheep):
	if sheep.selection_id in used_selection_ids.keys():
		sheep._on_go_to_sheep(sheep)
	else:
		used_selection_ids[sheep.selection_id] = sheep
		emit_signal("go_to_sheep", sheep)

func _on_go_to_sheep(sheep):
	used_selection_ids[sheep.selection_id] = sheep

func set_bounds(bounds):
	self.bounds = bounds
	$Camera2D.set_bounds(bounds)
