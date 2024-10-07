extends Area2D

const max_detection_distance = 250
var player_in_zone:Node2D = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player_in_zone: return
	if not self.get_meta("track_name"): return
	if not self.get_meta("volume_range"): return
	var _range: Vector2 = self.get_meta("volume_range", Vector2.ZERO)
	var _vol = lerp(_range.x, _range.y, get_proximity(player_in_zone))
	
	SoundManager.SOUND_MANAGER.change_soundtrack_volume(
		self.get_meta("track_name"), _vol)

func _on_body_entered(body: Node2D) -> void:
	if body.has_meta("is_player"):
		player_in_zone = body
	
func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		player_in_zone = null

func get_proximity(other:Node2D) -> float:
	var distance = (player_in_zone.global_position - global_position).length()
	
	if distance <= 0: return 1
	if distance >= max_detection_distance: return 0
	return 1 - (distance / max_detection_distance)
