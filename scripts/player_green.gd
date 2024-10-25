extends CharacterBody2D

const GRAVITY : int = 10
@export var jump_force : int = 400
@export var speed : int = 100
@onready var anim : AnimatedSprite2D = $anim as AnimatedSprite2D
@onready var screen_size = get_viewport_rect().size
@onready var bounce_sound : AudioStreamPlayer = $bounce_sound
@onready var bounce_sound2 : AudioStreamPlayer = $bounce_sound2
var input_direction : float = 0.0


# Variáveis para o estado dos botões
var left_button_pressed = false
var right_button_pressed = false

func move(delta):

	if left_button_pressed:
		input_direction = -1
	elif right_button_pressed:
		input_direction = 1
	elif Input.get_axis("ui_left","ui_right") == 0:
		input_direction = 0
	else :
		input_direction = Input.get_axis("ui_left","ui_right")

	
	if input_direction != 0:
		#acelera de acordo com o input
		velocity.x = lerp(velocity.x, input_direction * speed, 0.5)
		anim.scale.x = -input_direction
	else:
		#desacelera de acordo com o input
		velocity.x = lerp(velocity.x, 0.0, 0.5)
	
	velocity.y += GRAVITY
	var collision = move_and_collide(velocity * delta)
	
	#seta as animações
	if velocity.y > 0 :
		anim.play("fall")
	else:
		anim.play("idle")
	
	if collision:
		if collision.get_collider().jump_force > 1:
			bounce_sound2.play()
		else :
			bounce_sound.play()
			
		velocity.y = -jump_force * collision.get_collider().jump_force
		if collision.get_collider().has_method("response"):
			collision.get_collider().response()
	
func _physics_process(delta: float) -> void:
	move(delta)
	position.x = wrapf(position.x, 0.0, screen_size.x)

# Função chamada quando o botão da esquerda é pressionado
func _on_left_button_pressed() -> void:
	print("Botão da esquerda pressionado")
	left_button_pressed = $LeftButton.is_pressed()

# Função chamada quando o botão da direita é pressionado
func _on_right_button_pressed() -> void:
	print("Botão da direita pressionado")
	right_button_pressed = $RightButton.is_pressed()


func die() -> void:
	print("Morreu")
	velocity = Vector2.ZERO
	set_collision_mask_value(1, false)