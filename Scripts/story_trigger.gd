extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_meta("is_player"):
		collision_shape_2d.disabled = true
		audio_stream_player_2d.play()

func _on_audio_stream_player_2d_finished() -> void:
	sprite_2d.self_modulate = Color.DIM_GRAY
	audio_stream_player_2d.volume_db = -80
