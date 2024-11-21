extends Control

@onready var highscore : Label = $main/high_score
@onready var music : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
  music.play()
  if highscore:
    highscore.text = "Highscore:\n" + str(Global.highscore)
  else:
    printerr("Highscore label not found")

func _on_start_btn_pressed():
  #esperar um tempo antes de trocar
  await get_tree().create_timer(0.5).timeout
  if get_tree().change_scene_to_file("res://scenes/doodle_jump.tscn") != OK:
    printerr("Failed to change scene")

func _on_exit_btn_pressed() -> void:
  get_tree().quit()
	
