extends CanvasLayer

var points_shown = 0
var total_points = -1
var time_passed = 0.0
var total_sheep_saved = -1
var total_sheep_lost = -1
var total_slimes_destroyed = -1
var sheep_saved_shown = 0
var sheep_lost_shown = 0
var slimes_destroyed_shown = 0
var time_to_wait = 0.128
var is_punching = false
var is_end_game = false

func _ready():
	$"/root/GlobalState".connect("game_over", self, "_on_game_over")


func _process(delta):
	if is_punching:
		return
	time_passed += delta
	if time_passed > time_to_wait:
		time_passed = 0 
		if total_sheep_saved > sheep_saved_shown:
			sheep_saved_shown += 1
			$VBoxContainer/SheepSavedBox/SheepSaved.text = str(sheep_saved_shown)
		elif total_sheep_saved == sheep_saved_shown:
			sheep_saved_shown += 1 # yeah this is probably bad practice :)
			MakeMultiplierPunchy($VBoxContainer/SheepSavedBox/SheepSaved, "sheep")
		elif total_sheep_lost > sheep_lost_shown:
			sheep_lost_shown += 1
			$VBoxContainer/SheepLostBox/SheepLost.text = str(sheep_lost_shown)
		elif total_sheep_lost == sheep_lost_shown:
			sheep_lost_shown += 1
			MakeMultiplierPunchy($VBoxContainer/SheepLostBox/SheepLost, "dead")
		elif total_slimes_destroyed > slimes_destroyed_shown:
			slimes_destroyed_shown += 1
			$VBoxContainer/SlimesDestroyedBox/SlimesDestroyed.text = str(slimes_destroyed_shown)
		elif total_slimes_destroyed == slimes_destroyed_shown:
			slimes_destroyed_shown += 1
			MakeMultiplierPunchy($VBoxContainer/SlimesDestroyedBox/SlimesDestroyed, "slime")
		elif total_points > points_shown:
			time_to_wait = 0.01
			points_shown += 5
			$VBoxContainer/PointsBox/Points.text = str(points_shown)
		elif total_points == points_shown:
			points_shown += 1
			yield(get_tree().create_timer(1), "timeout")
			$VBoxContainer/NextLevel/NextLevelButton.visible = true

func MakeMultiplierPunchy(label : Label, point_name : String):
	is_punching = true
	yield(get_tree().create_timer(0.2), "timeout")
	var text = label.text
	text += " x "
	label.text = text
	yield(get_tree().create_timer(0.2), "timeout")
	text += str($"/root/GlobalState".point_values[point_name])
	label.text = text
	is_punching = false

func UpdatePoints(points):
	if is_end_game:
		$Label.visible = true
	$VBoxContainer.visible = true

func _on_game_over(points, sheep_saved, sheep_lost, slimes_destroyed):
	get_tree().paused = true
	UpdatePoints(points)
	self.total_points = points
	self.total_sheep_saved = sheep_saved
	self.total_sheep_lost = sheep_lost
	self.total_slimes_destroyed = slimes_destroyed


func _on_NextLevelButton_pressed():
	$"/root/GlobalState".go_to_next_level()


func _on_ResetLevel_pressed():
	$"/root/GlobalState".reload_level()
