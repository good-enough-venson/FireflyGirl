extends Area2D

func _process(delta: float) -> void:
	if GameManager.GAME_MANAGER:
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.modulate = Color.WHITE
	else:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.modulate = Color.DARK_ORANGE

func _on_body_entered(body: Node2D) -> void:
	if body.get_meta("is_player"):
		var linked_level:String = get_meta("linked_to")
		print("Attempting warp to ({l})...".format({"l":linked_level}))
		if GameManager.GAME_MANAGER != null:
			print("Sending Warp Request.")
			GameManager.GAME_MANAGER.on_enter_gate_to(linked_level)
		else: print("Gate Nexus Unavailable!")
