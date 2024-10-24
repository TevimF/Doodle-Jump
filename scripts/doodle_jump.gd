extends Node2D

@onready var platform_container : Node2D = $platform_container
@onready var platform_initial_position_y : float = $platform_container/platform.position.y
@onready var camera : Camera2D = $camera
@onready var player : CharacterBody2D = $player
@onready var score_label = $camera/score_label
@onready var camera_start_position : int = $camera.position.y

@export var platform_scene : Array[PackedScene] = []

var score : int = 0
var level_1 = 333



func _ready() -> void:	
	level_generator(7)

func level_generator(amount):
	for items in amount:
		if score < level_1 :
			platform_initial_position_y -= randf_range(40.0, 60.0)
		else :
			platform_initial_position_y -= randf_range(60.0, 80.0)
		
		var random_number : int = randi() % 100
		
		#desbloqueio de plataformas
		if score > level_1:
			random_number += 10
		elif score > 2*level_1:
			random_number += 10
		elif score > 4*level_1:
			random_number += 30

		#seleção de plataforma
		var new_platform : StaticBody2D

		#plataforma de mola
		if random_number < 15:
			new_platform = platform_scene[3].instantiate() as StaticBody2D

		#plataforma normal
		elif random_number < 70:
			new_platform = platform_scene[0].instantiate() as StaticBody2D

		# variação da plataforma normal
		elif random_number < 100:
			# 1 ou 2
			new_platform = platform_scene[1 + randi() % 2 ].instantiate() as StaticBody2D
		
		#plataforma de nuvem
		else:
			new_platform = platform_scene[4].instantiate() as StaticBody2D
			new_platform.connect("delete_object", Callable(self, "delete_object"))

		if new_platform != null:
			new_platform.position = Vector2(randf_range(16.0,164.0), platform_initial_position_y)
			platform_container.call_deferred("add_child", new_platform)
		else:
			print("Plataforma ", new_platform, " não encontrada")

	
func _physics_process(_delta: float) -> void:
	if player.position.y < camera.position.y :
		camera.position.y = player.position.y 
	update_score()

func update_score() -> void:
	score = int((camera_start_position - camera.position.y)/10)
	score_label.text = "Score: " + str(score)

func delete_object(object : Node2D) -> void:
	if object.is_in_group("player") :
		print("GAME OVER")
	if object.name == "cloud_platform" :
		var tween = get_tree().create_tween()
		tween.tween_property(object, "modulate", Color(1, 1, 1, 0), 1)
		tween.connect("finished", Callable(object, "queue_free"))
		level_generator(1)
	elif object.is_in_group("platform") :
		object.queue_free()
		level_generator(1)
	


func _on_platform_cleaner_body_entered(body: Node2D) -> void:
	body.queue_free()
	level_generator(1)
