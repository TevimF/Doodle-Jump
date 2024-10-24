extends "res://scripts/platform.gd"

func response():
  $spring.play("default")

func _on_spring_animation_finished() -> void:
  $spring.frame = 0
