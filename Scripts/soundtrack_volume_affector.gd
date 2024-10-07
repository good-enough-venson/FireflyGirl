extends Area2D

const max_detection_distance = 2048
var player_in_zone: Node2D = null

var valid_track_name = false
var track_name = ""
var volume_min = -80
var volume_max = -80

func _ready() -> void:
	if not self.get_meta("track_name"): return
	if not self.get_meta("volume_range"): return
	track_name = get_meta("track_name")
	var _range: Vector2 = self.get_meta("volume_range", Vector2.ZERO)
	volume_min = _range.x
	volume_max = _range.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player_in_zone: return
	var _vol = lerp(volume_min, volume_max, get_proximity(player_in_zone))
	#print("vol: {v} prox: {p}".format({"v":_vol, "p":get_proximity(player_in_zone)}))
	SoundManager.SOUND_MANAGER.change_soundtrack_volume(track_name, _vol)

func _on_body_entered(body: Node2D) -> void:
	if body.has_meta("is_player"):
		player_in_zone = body
	
func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		SoundManager.SOUND_MANAGER.change_soundtrack_volume(track_name, volume_min)
		player_in_zone = null

func get_proximity(other:Node2D) -> float:
	var distance = (player_in_zone.global_position - global_position).length()
	if distance <= 0: return 1
	if distance >= max_detection_distance: return 0
	return 1 - (distance / max_detection_distance)
