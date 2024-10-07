extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_meta("is_player"):
		audio_stream_player_2d.play()

func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
