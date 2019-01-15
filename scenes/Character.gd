extends KinematicBody2D

export (int) var speed = 100

var screensize
var velocity = Vector2()
var action = ""
var attackStyle = ""
var is_on_floor = true

func _ready():	
	screensize = get_viewport_rect().size

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('right') && action != "attacking":
		velocity.x += 1
		action = "running"
	if Input.is_action_pressed('left') && action != "attacking":
		velocity.x -= 1
		action = "running"
	if Input.is_action_pressed('down') && action != "attacking":
		velocity.y += 1
		action = "running"
	if Input.is_action_pressed('up') && action != "attacking":
		velocity.y -= 1
		action = "running"
	if Input.is_action_pressed('lightattack') && action != "attacking":
		action = "attacking"
		attackStyle = "light"
	if Input.is_action_pressed('heavyattack') && action != "attacking":
		action = "attacking"
		attackStyle = "heavy"
	if Input.is_action_just_released('lightattack') || Input.is_action_just_released('heavyattack'):
		action = "none"	
	if Input.is_action_pressed('jump') && action != "attacking" && is_on_floor == true:
		action = "jumping"
		is_on_floor = false
	if Input.is_action_pressed('slide') && action != "attacking" && action != "sliding":
		action = "sliding"
			
	velocity = velocity.normalized() * speed
	
	if action == "running" && velocity.length() > 0:
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.play("running")
	elif action == "attacking" && attackStyle == "light":
		$AnimatedSprite.play('lightattack')
	elif action == "attacking" && attackStyle == "heavy":
		$AnimatedSprite.play('heavyattack')
	elif action == "jumping":
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.play('jump')
		is_on_floor = true
	elif action == "sliding":
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.play('slide')
	else:
		$AnimatedSprite.play("idle")

func _process(delta):
	get_input()
	move_and_slide(velocity)