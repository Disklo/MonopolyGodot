extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var sprite_dados = [
	load("res://assets/sprites/dados/front&side-1.png"),
	load("res://assets/sprites/dados/front-2.png"),
	load("res://assets/sprites/dados/front-3.png"),
	load("res://assets/sprites/dados/front&side-4.png"),
	load("res://assets/sprites/dados/front-5.png"),
	load("res://assets/sprites/dados/front-6.png")
]

var rodando = false
var pos_inicial: Vector2
var pos_destino: Vector2

func _ready() -> void:
	# Setando a posição inicial do dado antes da animação de rolar eles acontecer
	pos_inicial = Vector2(-700.0, 5000.0)

func mostrar_valor(valor: int):
	if valor >= 1 and valor <= 6:
		sprite.texture = sprite_dados[valor - 1]
		
func animar_para(valor_final: int, destino: Vector2 = Vector2.ZERO):
	rodando = true
	
	if destino != Vector2.ZERO:
		pos_destino = destino
	else:
		pos_destino = position
	
	var duracao = 2
	var intervalo = 0.10
	var num_trocas = int(duracao / intervalo)
	position = pos_inicial
	
	#Criar tween de animação para mover o dado
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	# Move o dado para a posição de destino
	tween.tween_property(self, "position", pos_destino, duracao)
	
	# Loop de animação para trocar os valores do dado enquanto ele se move
	for i in range(num_trocas):
		var valor_aleatorio = randi_range(1, 6)
		mostrar_valor(valor_aleatorio)
		await get_tree().create_timer(intervalo).timeout
		
	tween.finished
	
	# Mostrando o valor correto
	mostrar_valor(valor_final)
	rodando = false
