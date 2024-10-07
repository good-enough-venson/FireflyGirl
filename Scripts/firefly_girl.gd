extends CharacterBody2D

const VSPEED = 80.0
const HSPEED = 120.0
const JUMP_VELOCITY = 10
const DEFAULT_GRAB_JUMP = 50
const MAX_GRAB_JUMP = 120

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var fireflies_list: Array[Node2D] = []
var is_grabbing = false
var grab_target: Vector2
var potential: int = 0

func _process(delta: float) -> void:
	if is_grabbing:
		if animated_sprite.animation == "grab" and animated_sprite.is_playing(): return
		else:
			is_grabbing = false
			potential = 0
	
	if Input.is_action_just_pressed("grab_fly"):
		var closest_fireflies = get_closest_fireflies()
		if closest_fireflies:
			grab_target = global_position.move_toward(closest_fireflies.global_position, MAX_GRAB_JUMP)
			animated_sprite.flip_h = grab_target.x < global_position.x
			potential = closest_fireflies.on_grab_attempt(self)
			print("Trying for {p} fireflies..".format({"p":potential}))
		else:
			grab_target = global_position + DEFAULT_GRAB_JUMP * (
				Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT)
		
		is_grabbing = true
		animated_sprite.play("grab")

func _physics_process(delta: float) -> void:
	if is_grabbing:
		velocity = (grab_target - global_position) * JUMP_VELOCITY
		move_and_slide()
		return
	
	var input_vector = Vector2(
		Input.get_axis("walk_left", "walk_right"),
		Input.get_axis("walk_up", "walk_down")
		).normalized()
	
	if input_vector.x:
		velocity.x = input_vector.x * HSPEED
		#animated_sprite.play("walk")
		animated_sprite.flip_h = (velocity.x < 0)
	else: velocity.x = move_toward(velocity.x, 0, HSPEED)
	
	if input_vector.y:
		velocity.y = input_vector.y * VSPEED
		#animated_sprite.play("walk")
	else: velocity.y = move_toward(velocity.y, 0, VSPEED)

	#print(velocity.length())
	animated_sprite.play("idle" if velocity.length() < 1 else "walk")

	move_and_slide()

func on_approach_fireflies(fireflies:Node2D):
	if fireflies_list.find(fireflies) < 0:
		fireflies_list.append(fireflies)
		print("approached fireflies")

func on_leave_fireflies(fireflies:Node2D):
	var _i = fireflies_list.find(fireflies)
	if _i >= 0:
		fireflies_list.remove_at(_i)
		print("left fireflies")

func get_closest_fireflies() -> Node2D:
	var distance:float = 99999999
	var fireflies:Node2D = null
	
	for _ff in fireflies_list:
		var _d = global_position.distance_squared_to(_ff.global_position)
		if _d < distance:
			fireflies = _ff
			distance = _d
			
	return fireflies

func on_fireflies_displaced(fireflies:Node2D):
	if is_grabbing and potential > 0:
		add_fireflies(potential)
		potential = 0

func add_fireflies(count:int):
	print("Caught {c} fireflies!".format({"c":count}))
