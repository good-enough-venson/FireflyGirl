extends Node2D

class_name GameManager
static var GAME_MANAGER:GameManager = null

const FIRST_LEVEL = "menu_scene"

var total_fireflies_caught: int = 0

var currentLevel: Node2D

var preloaded_scenes = {
	"menu_scene": preload("res://Scenes/menu_scene.tscn"),
	"forest_scene": preload("res://Scenes/forest_scene.tscn"),
	"pond_scene": preload("res://Scenes/pond_scene.tscn"),
	"bridge_scene": preload("res://Scenes/bridge_scene.tscn"),
	"backyard_scene": preload("res://Scenes/backyard_scene.tscn"),
	"playground_scene": preload("res://Scenes/playground_scene.tscn"),
	"endgame_scene": preload("res://Scenes/EndGameScene.tscn")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GAME_MANAGER = self
	var _ml = self.get_meta("first_level")
	if _ml and preloaded_scenes.has(_ml):
		load_scene(_ml)
	else: load_scene(FIRST_LEVEL)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Warp gates call this function.
func on_enter_gate_to(destinaton:String):
	load_scene(destinaton)

func load_scene(scene_name:String):
	unload_scene()
	var path := "res://Scenes/{l}.tscn".format({"l":scene_name})
	var level := load(path)
	if level:
		currentLevel = level.instantiate()
		add_child(currentLevel)

func unload_scene():
	if is_instance_valid(currentLevel):
		currentLevel.queue_free()
		currentLevel = null
