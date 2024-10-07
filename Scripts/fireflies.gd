extends Area2D

var scatterfly_scene = preload("res://Scenes/fireflies_scatter.tscn")

@onready var firefly_1: AnimatedSprite2D = $Firefly_1
@onready var firefly_2: AnimatedSprite2D = $Firefly_2
@onready var firefly_3: AnimatedSprite2D = $Firefly_3
@onready var firefly_4: AnimatedSprite2D = $Firefly_4
@onready var firefly_5: AnimatedSprite2D = $Firefly_5
@onready var firefly_6: AnimatedSprite2D = $Firefly_6

@onready var fireflies_array: Array[AnimatedSprite2D] = [
	$Firefly_1, $Firefly_2, $Firefly_3, $Firefly_4, $Firefly_5, $Firefly_6
]

const AVAILABLE_FIREFLIES = 3

const flicker_rate = 1.5
const max_detection_distance = 250
const disperse_distance_range = Vector2(50, 100)
var disperse_distance: float = 0

var player_in_zone:Node2D = null

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	disperse_distance = rng.randf_range(disperse_distance_range.x, disperse_distance_range.y)
	animate_fireflies(0)

func _process(delta: float) -> void:
	# We want to scale the numbers of fireflies around by the distance from the player to the dispersal threshold.
	# The closer the player, the more fireflies are lit. However, this shouldn't be a dead giveaway.
	# The player needs to be somewhat unsure of how close she can get before the fireflies will scatter.
	#var lit_chance = 0
	#var _log = "fireflies log:"
	
	if player_in_zone:
		if global_position.distance_squared_to(player_in_zone.global_position) < disperse_distance * disperse_distance:
			player_in_zone.on_fireflies_displaced(self)
			scatter()
			return
		
		animate_fireflies(get_proximity(player_in_zone, true))
		#lit_chance = get_proximity(player_in_zone)
		#print(lit_chance)
	
	#flicker(firefly_1, delta, lit_chance)
	#flicker(firefly_2, delta, lit_chance)
	#flicker(firefly_3, delta, lit_chance)
	#flicker(firefly_4, delta, lit_chance)
	#flicker(firefly_5, delta, lit_chance)
	#flicker(firefly_6, delta, lit_chance)
	
func flicker(sprite:AnimatedSprite2D, delta:float, chance:float):
	if rng.randf() < flicker_rate * delta:
		sprite.visible = rng.randf() < chance

func animate_fireflies(amount:float):
	var flies_needed = min(ceil(
		amount * fireflies_array.size()),
		fireflies_array.size())
		
	if flies_needed <= 0: return
	
	var lit = fireflies_array.filter(func(fly): return fly.visible)
	var unlit = fireflies_array.filter(func(fly): return !fly.visible)
	
	print("fireflies {l}/{t} -> {a}. Prox: {p}".format(
		{"l":lit.size(), "t":flies_needed, "a":amount, "p":disperse_distance}))
	
	while lit.size() > flies_needed:
		var _i = rng.randi() % lit.size()
		lit[_i].visible = false
		unlit.append(lit[_i])
		lit.remove_at(_i)
		
	while lit.size() < flies_needed:
		var _i = rng.randi() % unlit.size()
		unlit[_i].visible = true
		lit.append(unlit[_i])
		unlit.remove_at(_i)

func _on_body_entered(body: Node2D) -> void:
	if body.has_meta("is_player"):
		#print("{n} has entered zone.".format({"n":body.name}))
		player_in_zone = body
		player_in_zone.on_approach_fireflies(self)
		disperse_distance = rng.randf_range(
			disperse_distance_range.x, disperse_distance_range.y)
	
func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		#print("{n} has left zone.".format({"n":body.name}))
		player_in_zone.on_leave_fireflies(self)
		player_in_zone = null

func scatter():
	if player_in_zone: player_in_zone.on_leave_fireflies(self)
	var scatterfly_instance:Node2D = scatterfly_scene.instantiate()
	add_sibling(scatterfly_instance)
	scatterfly_instance.position = position
	queue_free()

func on_grab_attempt(player:Node2D) -> int:
	return floor(get_proximity(player) * AVAILABLE_FIREFLIES)

func get_proximity(other:Node2D, ignore_disperse_distance = false) -> float:
	var disp_dist = 0 if ignore_disperse_distance else disperse_distance
	var distance = (player_in_zone.global_position - global_position).length() - disp_dist
	var perimeter = max_detection_distance - disp_dist
	
	if distance <= 0: return 1
	if distance >= perimeter: return 0
	return 1 - (distance / perimeter)
