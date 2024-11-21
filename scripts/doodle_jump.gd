extends Node2D

@onready var platform_container : Node2D = $platform_container
@onready var platform_initial_position_y : float = $platform_container/platform.position.y
@onready var base_platform : StaticBody2D = $platform_container/base_platform
@onready var camera : Camera2D = $camera
@onready var player : CharacterBody2D = $player
@onready var score_label = $camera/score_label
@onready var camera_start_position : int = $camera.position.y

@export var platform_scene : Array[PackedScene] = []

var score : int = 0
var level_1 = 200
var last_passarim : bool = false
var max_height_possible : int = 500
var end_game : bool = false
var player_stopped : bool = false



func _ready() -> void:
	level_generator(7)
	player.connect("player_stopped", Callable(self, "_on_player_stopped"))
	$bg_music.play()

func level_generator(amount):
	if (end_game):
		return

	for items in amount:
		if score < level_1 :
			platform_initial_position_y -= randf_range(40.0, 60.0)
		else :
			platform_initial_position_y -= randf_range(60.0, 80.0)
		
		var random_number : int = randi() % 100
		
		#desbloqueio de plataformas
		if score > level_1:
			random_number += 5
		elif score > 2*level_1:
			random_number += 10

		#seleção de plataforma
		var new_platform : StaticBody2D

		if score >= max_height_possible && end_game == false:
			new_platform = platform_scene[6].instantiate() as StaticBody2D
			if new_platform != null:
				new_platform.jump_force = 0
				new_platform.position = Vector2(19, platform_initial_position_y)
				platform_container.call_deferred("add_child", new_platform)
				end_game = true
			else:
				print("Plataforma ", new_platform, " não encontrada")
			return


		#plataforma de mola
		if random_number < 11:
			new_platform = platform_scene[3].instantiate() as StaticBody2D

		#plataforma normal
		elif random_number < 65:
			last_passarim = false
			new_platform = platform_scene[0].instantiate() as StaticBody2D

		# variação da plataforma normal
		elif random_number < 80:
			# 1 ou 2
			last_passarim = false
			new_platform = platform_scene[1 + randi() % 2 ].instantiate() as StaticBody2D

		# passarim
		elif random_number < 85 && !last_passarim:
			last_passarim = true
			platform_initial_position_y += 10
			new_platform = platform_scene[5].instantiate() as StaticBody2D

		#plataforma de nuvem
		else:
			last_passarim = false
			new_platform = platform_scene[4].instantiate() as StaticBody2D
			new_platform.connect("delete_object", Callable(self, "delete_object"))

		if new_platform != null:
			new_platform.position = Vector2(randf_range(16.0,164.0), platform_initial_position_y)
			platform_container.call_deferred("add_child", new_platform)
		else:
			print("Plataforma ", new_platform, " não encontrada")

	
func _physics_process(_delta: float) -> void:
	#verifica se o player ainda existe
	if player == null :
		await get_tree().create_timer(1.0).timeout
		if get_tree().change_scene_to_file("res://scenes/title_screen.tscn") != OK:
			printerr("Failed to change scene")
		return

	if  player.position.y < camera.position.y :
		camera.position.y = player.position.y 
	update_score()

func update_score() -> void:
	score = int((camera_start_position - camera.position.y)/10)
	score_label.text = "Score: " + str(score)
	if score > Global.highscore :
		Global.highscore = score

func delete_object(object : Node2D) -> void:
	if object.name == "cloud_platform" :
		var tween = get_tree().create_tween()
		tween.tween_property(object, "modulate", Color(1, 1, 1, 0), 1)
		tween.connect("finished", Callable(object, "queue_free"))
		object.name = "fading_cloud_platform"  # muda o nome para evitar que o objeto seja deletado novamente
		level_generator(1)
	elif object.is_in_group("platform") :
		object.queue_free()
		level_generator(1)
	
func _on_player_stopped() -> void:
	if not player_stopped:
		player_stopped = true
		$bg_music.stop()
		await get_tree().create_timer(1.0).timeout
		$clap_song.play()
		$meme_song.play()
		$camera/motivacional.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property($camera/motivacional, "modulate:a", 1.0, 5.0)
		await tween.finished
		await $clap_song.finished
		if get_tree().change_scene_to_file("res://scenes/title_screen.tscn") != OK:
			printerr("Failed to change scene")


func _on_platform_cleaner_body_entered(body: Node2D) -> void:
	body.queue_free()
	level_generator(1)
