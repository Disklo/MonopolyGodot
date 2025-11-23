# Define a classe para um jogador.
extends Node

class_name Jogador

# Variáveis do jogador
@export var nome: String = "Jogador"
@export var dinheiro: int = 1500

# Posição atual do jogador no tabuleiro (índice do espaço)
var posicao: int = 0

# Lista de propriedades que o jogador possui
var propriedades: Array[Propriedade] = []

# Referência ao nó do peão do jogador na cena (para movimento visual)
# Esta variável precisará ser associada ao nó correto na cena do Godot.
@export var peao: Node2D

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
	$"../botaoRolarDados".disabled = false


# Move o jogador direto para uma posicção específica
func mover_para_posicao(nova_posicao: int, tabuleiro: Tabuleiro) -> void:
	var posicao_inicial = posicao
	posicao = nova_posicao
	print('%s foi movido diretamente para a posicao %d' % [nome, posicao])
	
	if peao == null:
		return
		
	# Movendo o peão (peça do jogador) diretamente para a nova posicão
	var espaco_destino = tabuleiro.obter_espaco(nova_posicao)
	if espaco_destino != null:
		var destino = espaco_destino.position + Vector2(200,200)
		# Animação
		var tween = create_tween()
		tween.tween_property(peao, "position", destino, 0.5)
		await tween.finished


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
