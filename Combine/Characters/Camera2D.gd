extends Camera2D

var bounds = {}

var margin = 100
var speed = 1500
# Lower cap for the `_zoom_level`.
export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
export var max_zoom := 10.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
export var zoom_factor := 0.4
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2
# The camera's target zoom level.
var _zoom_level := 5.0 setget _set_zoom_level
# We store a reference to the scene's tween node.
onready var tween: Tween = $Tween
var can_move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_move:
		move(delta)

func move(delta : float):
	var size = get_viewport_rect().size
	var mouse_position = get_viewport().get_mouse_position()
	if mouse_position.x > size.x or mouse_position.x < 0 or  mouse_position.y > size.y or mouse_position.y < 0:
		return
	var direction = Vector2.ZERO
	if mouse_position.x < margin:
		direction.x = -1
	if mouse_position.y < margin:
		direction.y = -1
	if mouse_position.x > (size.x - margin):
		direction.x = 1
	if mouse_position.y  > (size.y - margin):
		direction.y = 1
	
	clamp_position(position, direction * speed  * delta)
	
func clamp_position(position : Vector2, velocity : Vector2):
	var potential_position = position + velocity
	var x = clamp(potential_position.x, (bounds["topLeft"].x - get_viewport().size.x / 2), (bounds["bottomRight"].x + get_viewport().size.x / 2))
	var y = clamp(potential_position.y, (bounds["topLeft"].y / 2) + 50, (bounds["bottomRight"].y / 2) - 50)
	self.position = Vector2(x, y)
	
func _unhandled_input(event):
	if event.is_action_pressed("scroll_up"):
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("scroll_down"):
		_set_zoom_level(_zoom_level + zoom_factor)
		
		
func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(_zoom_level, _zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	tween.start()


func _notification(notification):
	match notification:
		NOTIFICATION_WM_MOUSE_EXIT:
			can_move = false
		NOTIFICATION_WM_MOUSE_ENTER:
			can_move = true

func set_bounds(bounds):
	self.bounds = bounds
