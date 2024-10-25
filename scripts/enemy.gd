extends "res://scripts/platform.gd"

var direction : Vector2 
var velocity : Vector2 
@export var speed : float = 100

@onready var screen_size = get_viewport_rect().size
@onready var anim = $anim as AnimatedSprite2D

func _ready() -> void:
    direction = Vector2.RIGHT
    anim.flip_h = true
    velocity = Vector2.ZERO
    anim.play("default")

func _physics_process(delta: float) -> void:
    movment(delta)



func movment(delta : float) -> void:
    # delta é o tempo que passou desde a última atualização
    velocity = direction * speed
    position += velocity * delta
    if position.x < 0:
        direction = Vector2.RIGHT
        anim.flip_h = true
    if position.x > screen_size.x:
        direction = Vector2.LEFT
        anim.flip_h = false



func _on_hitbox_body_entered(body:Node2D) -> void:
    if body.is_in_group("player") and body.has_method("die"):
        body.die()
