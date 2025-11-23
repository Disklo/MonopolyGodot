# Define a classe para um jogador.
extends Node2D

class_name Jogador

@onready var peao: Sprite2D = $Peao
# Variáveis do jogador
@export var nome: String = "Jogador"
@export var dinheiro: int = 15009

# Posição atual do jogador no tabuleiro (índice do espaço)
var posicao: int = 0
var index: int = 0 # Índice do jogador (0 a 3) para evitar sobreposição
signal movimento_concluido(jogador: Jogador)
signal dinheiro_alterado(novo_saldo: int)
# Lista de propriedades que o jogador possui
var propriedades: Array[Propriedade] = []

# Variáveis de estado da prisão
var preso: bool = false
var turnos_na_prisao: int = 0

func set_cor(c: Color) -> void:
	peao.modulate = c

# Move o jogador no tabuleiro
func mover(passos: int, tabuleiro: Tabuleiro) -> void:
	var posicao_inicial = posicao
	posicao = (posicao + passos) % 40 # 40 é o número padrão de espaços no Monopoly
	print("%s moveu para a posição %d" % [nome, posicao])
	
	if peao == null:
		return
	
	# Define o offset com base no índice do jogador para evitar sobreposição
	var offset = Vector2.ZERO
	match index:
		0: offset = Vector2(-30, -30)
		1: offset = Vector2(30, -30)
		2: offset = Vector2(-30, 30)
		3: offset = Vector2(30, 30)
	
	# Criando a animação com Tween
	var tween = create_tween()
	tween.set_parallel(false)
	
	for i in range(1, passos + 1):
		var casa_atual = (posicao_inicial + i) % 40
		var espaco_atual = tabuleiro.obter_espaco(casa_atual)
	
		if espaco_atual != null:
			var destino = espaco_atual.position + Vector2(200, 200) + offset
			# Animando o movimento do peão
			tween.tween_property(peao, "position", destino, 0.3).set_delay(0.2)
	
	await tween.finished
	movimento_concluido.emit(self)


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
	dinheiro_alterado.emit(dinheiro)
	print("%s pagou %d. Saldo: %d" % [nome, valor, dinheiro])

# Adiciona dinheiro ao jogador
func receber(valor: int) -> void:
	dinheiro += valor
	dinheiro_alterado.emit(dinheiro)
	print("%s recebeu %d. Saldo: %d" % [nome, valor, dinheiro])

func ir_para_prisao() -> void:
	preso = true
	turnos_na_prisao = 0
	print("%s foi enviado para a prisão (estado atualizado)." % nome)

func sair_da_prisao() -> void:
	preso = false
	turnos_na_prisao = 0
	print("%s saiu da prisão." % nome)
