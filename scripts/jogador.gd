# Define a classe para um jogador.
extends Node2D

class_name Jogador

@onready var peao:Sprite2D = $Peao
# Variáveis do jogador
@export var nome: String = "Jogador"
@export var dinheiro: int = 1500

# Posição atual do jogador no tabuleiro (índice do espaço)
var posicao: int = 0
signal movimento_concluido(jogador: Jogador)
# Lista de propriedades que o jogador possui
var propriedades: Array[Propriedade] = []

func  set_cor(c: Color) -> void:
	peao.modulate = c

# Move o jogador no tabuleiro
func mover(passos: int, tabuleiro: Tabuleiro) -> void:
	var posicao_inicial = posicao
	posicao = (posicao + passos) % 40 # 40 é o número padrão de espaços no Monopoly
	print("%s moveu para a posição %d" % [nome, posicao])
	
	if peao == null:
		return
	
	# Criando a animação com Tween
	var tween = create_tween()
	tween.set_parallel(false)
	
	for i in range(1, passos + 1):
		var casa_atual = (posicao_inicial + i) % 40
		var espaco_atual = tabuleiro.obter_espaco(casa_atual)
	
		if espaco_atual != null:
			var destino = espaco_atual.position + Vector2(200,200)
			# Animando o movimento do peão
			tween.tween_property(peao, "position", destino, 0.3).set_delay(0.2)
	
	await tween.finished
	movimento_concluido.emit(self)


# Adiciona uma propriedade à lista do jogador
func comprar_propriedade(propriedade: Propriedade) -> void:
	propriedades.append(propriedade)

# Verifica se o jogador possui todas as propriedades de um grupo de cor
func tem_monopolio(cor_grupo: String, tabuleiro: Tabuleiro) -> bool:
	var contagem_jogador = 0
	for p in propriedades:
		if p.cor_grupo == cor_grupo:
			contagem_jogador += 1
	
	var contagem_tabuleiro = tabuleiro.contar_propriedades_cor(cor_grupo)
	
	return contagem_jogador == contagem_tabuleiro

# Subtrai dinheiro do jogador
func pagar(valor: int) -> void:
	dinheiro -= valor
	print("%s pagou %d. Saldo: %d" % [nome, valor, dinheiro])

# Adiciona dinheiro ao jogador
func receber(valor: int) -> void:
	dinheiro += valor
	print("%s recebeu %d. Saldo: %d" % [nome, valor, dinheiro])
