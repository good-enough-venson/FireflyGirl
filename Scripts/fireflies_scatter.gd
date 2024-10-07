extends Node2D

func _ready() -> void:
	print("The fireflies scatter before you.")

func _on_timer_timeout() -> void:
	queue_free()
