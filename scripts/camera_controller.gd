extends Camera2D

var zoom_speed = 0.04
var min_zoom = 0.05
var max_zoom = 2.0
var move_speed = 1000

# Limites da câmera (ajustados para o tamanho do tabuleiro)
@export var camera_limit_left = -2500
@export var camera_limit_top = -2500
@export var camera_limit_right = 2000
@export var camera_limit_bottom = 2000

func _ready():
	zoom = Vector2(0.1, 0.1)

func _process(delta):
	# Mover a câmera com as teclas de seta
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity.y -= 1
	
	position += velocity.normalized() * move_speed * delta
	
	# Limitar a posição da câmera
	position.x = clamp(position.x, camera_limit_left, camera_limit_right)
	position.y = clamp(position.y, camera_limit_top, camera_limit_bottom)

	# Controlar zoom com teclado
	var zoom_change = Vector2()
	if Input.is_key_pressed(KEY_EQUAL): # Zoom Out
		zoom_change += Vector2(zoom_speed, zoom_speed)
	if Input.is_key_pressed(KEY_MINUS): # Zoom In
		zoom_change -= Vector2(zoom_speed, zoom_speed)
	
	zoom += zoom_change * delta * 20
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)

func _input(event):
	# Controlar o zoom com a roda do mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoom_speed, zoom_speed)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoom_speed, zoom_speed)
		
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
