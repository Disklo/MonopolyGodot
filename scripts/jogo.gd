# Script principal que gerencia o fluxo do jogo.
extends Node

class_name Jogo

@onready var dado1: Node2D = $Dado1
@onready var dado2: Node2D = $Dado2

# Referências aos nós da cena, configuráveis no editor
@export var tabuleiro: Tabuleiro
@export var jogadores: Array[Jogador]

# Variáveis para controlar o estado do jogo
var turno_atual: int = 0
var rodada_atual: int = 1
var jogador_atual: Jogador
var ultimo_resultado_dados: int = 0
@onready var botao_construir_casa: Button = $botaoConstruirCasa

# A função _ready é chamada quando o nó entra na árvore da cena.
func _ready() -> void:
	iniciar_jogo()

# Prepara o estado inicial do jogo.
func iniciar_jogo() -> void:
	# Adicionando referências dos nós.
	tabuleiro = get_node("Tabuleiro")
	
	# Adiciona todos os jogadores da cena
	for child in get_children():
		if child is Jogador:
			jogadores.append(child)
	
	if jogadores.is_empty() or tabuleiro == null:
		print("ERRO: Jogadores ou tabuleiro não configurados na cena Jogo.")
		return

	turno_atual = 0
	jogador_atual = jogadores[turno_atual]
	
	# Posicionar jogadores no ponto de partida
	var ponto_partida = tabuleiro.obter_espaco(0)
	if ponto_partida != null:
		for jogador in jogadores:
			if jogador.peao != null:
				jogador.peao.position = ponto_partida.position + Vector2(200, randi_range(100, 300))
	
	print("O jogo começou! É a vez de %s." % jogador_atual.nome)
	atualizar_ui_construcao()

# Passa para o próximo jogador.
func proximo_jogador() -> void:
	turno_atual = (turno_atual + 1) % jogadores.size()
	jogador_atual = jogadores[turno_atual]
	print("\n--- Próximo turno! É a vez de %s. ---" % jogador_atual.nome)
	atualizar_ui_construcao()
	verificar_rodada()

# Verifica se uma rodada terminou.
func verificar_rodada() -> void:
	if turno_atual == 0:
		rodada_atual += 1
		print("\n--- Rodada %d ---" % rodada_atual)

# Essa função deve ser conectada a um botão de "Rolar Dados" na UI
func _on_rolar_dados_apertado() -> void:
	rolar_dados()

func rolar_dados() -> void:
	print('rolando dados...')
	botao_construir_casa.visible = false
	
	# tornando os dados visíveis no tabuleiro
	$Dado1.visible = true
	$Dado2.visible = true
	
	# Desabilitando o botão para não haver mais cliques enquanto um turno acontece
	$botaoRolarDados.disabled = true
	
	if jogador_atual == null:
			print("Jogo não iniciado corretamente.")
			return
	
	# 1. Rola os valores individuais dos dados para mostrar visualmente
	var dado1_valor = randi_range(1, 6)
	var dado2_valor = randi_range(1, 6)
	
	# Calcula a posição de destino dos dados obs: soma-se 200 para que eles não caem na mesma posição
	#var centro_x = Vector2(-840.0, 155.0) #get_viewport().get_visible_rect().size.x / 2
	#var centro_y = Vector2(400.0, 145.0) #get_viewport().get_visible_rect().size.y / 2
	var destino_dado1 = Vector2(randi_range(-500.0, 500.0) + 200, randi_range(1200.0, -500.0) + 200)
	var destino_dado2 = Vector2(randi_range(-500.0, 500.0) + 200, randi_range(1200.0, -500.0) + 200)
	
	#var destino_dado1 = Vector2(centro_x + randi_range(-100,100), centro_y + randi_range(-100,100)) # Esquerda
	#var destino_dado2 = Vector2(centro_x + randi_range(-100,100), centro_y + randi_range(-100,100)) # Direita
	
	# Animação dos dados
	if dado1 and dado2:
		dado1.animar_para(dado1_valor, destino_dado1)
		dado2.animar_para(dado2_valor, destino_dado2)
		await get_tree().create_timer(2.8).timeout
	
	# A parte abaixo ficará comentada por enquanto	
	#else:
	#	if dado1:
	#		await dado1.animar_para(dado1_valor)
	#	if dado2:	
	#		await dado2.animar_para(dado2_valor)

	var passos = dado1_valor + dado2_valor
	print("%s rolou os dados: %d + %d = %d" % [jogador_atual.nome, dado1_valor, dado2_valor, passos])
	ultimo_resultado_dados = passos

	# 2. Move o jogador
	jogador_atual.mover(passos, tabuleiro)

	# 3. Obtém o espaço em que o jogador parou
	var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)

	# 4. Executa a ação daquele espaço
	if espaco_atual != null:
			espaco_atual.ao_parar(jogador_atual)

	# 5. Passa para o próximo turno
	# (Espera as animações terminarem antes do turno ser passado)
	proximo_jogador()

func _on_construir_casa_apertado() -> void:
	var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)
	if espaco_atual is Propriedade and espaco_atual.dono == jogador_atual:
		espaco_atual.construir_casa()
		atualizar_ui_construcao()

func atualizar_ui_construcao() -> void:
	var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)
	if espaco_atual is Propriedade and espaco_atual.dono == jogador_atual and jogador_atual.tem_monopolio(espaco_atual.cor_grupo, tabuleiro):
		botao_construir_casa.visible = true
	else:
		botao_construir_casa.visible = false

func _on_debug_construir_apertado() -> void:
	var propriedade = tabuleiro.obter_espaco(1) # Propriedade11
	if propriedade is Propriedade:
		if propriedade.dono == null:
			propriedade.dono = jogador_atual
			jogador_atual.propriedades.append(propriedade)
			# Forçar monopólio para teste
			var outra_prop = tabuleiro.obter_espaco(3) # Propriedade10
			if outra_prop is Propriedade and outra_prop.dono == null:
				outra_prop.dono = jogador_atual
				jogador_atual.propriedades.append(outra_prop)
		
		propriedade.construir_casa()
		atualizar_ui_construcao()
