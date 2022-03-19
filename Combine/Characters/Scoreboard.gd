extends CanvasLayer

var points_shown = 0
var total_points = 0
var time_passed = 0.0

func _ready():
	$"/root/GlobalState".connect("game_over", self, "_on_game_over")


func _process(delta):
	time_passed += delta
	if time_passed > 0.01:
		time_passed = 0 
		if total_points > points_shown:
			points_shown += 5
			$VBoxContainer/HBoxContainer/Points.text = str(points_shown)

func UpdatePoints(points):
	$VBoxContainer.visible = true
	total_points = points

func _on_game_over(points):
	UpdatePoints(points)
