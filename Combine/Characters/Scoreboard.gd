extends CanvasLayer

var points_shown = 0
var total_points = 0
var time_passed = 0.0
var total_sheep_saved = 0
var total_sheep_lost = 0
var total_slimes_destroyed = 0
var sheep_saved_shown = 0
var sheep_lost_shown = 0
var slimes_destroyed_shown = 0
var time_to_wait = 0.5

func _ready():
	$"/root/GlobalState".connect("game_over", self, "_on_game_over")


func _process(delta):
	time_passed += delta
	if time_passed > time_to_wait:
		time_passed = 0 
		if total_sheep_saved > sheep_saved_shown:
			sheep_saved_shown += 1
			$VBoxContainer/SheepSavedBox/SheepSaved.text = str(sheep_saved_shown)
		elif total_sheep_lost > sheep_lost_shown:
			sheep_lost_shown += 1
			$VBoxContainer/SheepLostBox/SheepLost.text = str(sheep_lost_shown)
		elif total_slimes_destroyed > slimes_destroyed_shown:
			slimes_destroyed_shown += 1
			$VBoxContainer/SlimesDestroyedBox/SlimesDestroyed.text = str(slimes_destroyed_shown)
		elif total_points > points_shown:
			time_to_wait = 0.01
			points_shown += 5
			$VBoxContainer/PointsBox/Points.text = str(points_shown)

func UpdatePoints(points):
	$VBoxContainer.visible = true

func _on_game_over(points, sheep_saved, sheep_lost, slimes_destroyed):
	UpdatePoints(points)
	self.total_points = points
	self.total_sheep_saved = sheep_saved
	self.total_sheep_lost = sheep_lost
	self.total_slimes_destroyed = slimes_destroyed
