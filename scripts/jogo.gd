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
@onready var botao_rolar_dados: Button = $botaoRolarDados

func _ready() -> void:
	iniciar_jogo()
	setup_debug_ui()

func setup_debug_ui() -> void:
	var y_offset = 0
	for i in range(jogadores.size()):
		var jogador = jogadores[i]
		var btn = Button.new()
		btn.text = "Prender %s" % jogador.nome
		# Posiciona no canto superior direito, abaixo um do outro
		btn.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
		btn.size = Vector2(200, 40)
		btn.pressed.connect(func(): _on_debug_prender_pressed(jogador))
		add_child(btn)
		y_offset += 50

func _on_debug_prender_pressed(jogador: Jogador) -> void:
	print("DEBUG: Prendendo %s" % jogador.nome)
	jogador.posicao = 10 # Índice da Prisão
	jogador.ir_para_prisao()
	
	# Move visualmente o peão para a prisão
	var espaco_prisao = tabuleiro.obter_espaco(10)
	if espaco_prisao != null:
		var offset = Vector2.ZERO
		match jogador.index:
			0: offset = Vector2(-30, -30)
			1: offset = Vector2(30, -30)
			2: offset = Vector2(-30, 30)
			3: offset = Vector2(30, 30)
		jogador.peao.position = espaco_prisao.position + Vector2(200, 200) + offset
	
	# Se for o turno do jogador preso, atualiza a UI
	if jogador == jogador_atual:
		botao_rolar_dados.visible = false
		exibir_popup_prisao()

func exibir_popup_prisao() -> void:
	if action_popup == null:
		setup_action_popup()
	
	action_popup.clear_buttons()
	action_popup.set_text("Você está preso! O que deseja fazer?")
	
	action_popup.add_button("Pagar Fiança (R$ 50)", func():
		if jogador_atual.dinheiro >= 50:
			jogador_atual.pagar(50)
			jogador_atual.sair_da_prisao()
			rolar_dados()
		else:
			print("Dinheiro insuficiente.")
			# Reexibe o popup ou avisa
			exibir_popup_mensagem("Dinheiro insuficiente para pagar a fiança.", func(): exibir_popup_prisao())
	)
	
	action_popup.add_button("Tentar Dados", func():
		rolar_dados()
	)
	
	action_popup.show_popup()

func exibir_popup_mensagem(texto: String, callback: Callable = Callable()) -> void:
	if action_popup == null:
		setup_action_popup()
	
	action_popup.clear_buttons()
	action_popup.set_text(texto)
	
	action_popup.add_button("OK", func():
		if not callback.is_null():
			callback.call()
	)
	
	action_popup.show_popup()

# Prepara o estado inicial do jogo.
func iniciar_jogo() -> void:
	# Adicionando referências dos nós.
	tabuleiro = get_node("Tabuleiro")
	
	jogadores.clear()
	# Adiciona todos os jogadores da cena
	for child in get_children():
		if child is Jogador:
			jogadores.append(child)
	
	var cores = [Color.BLUE, Color.RED, Color.GREEN, Color.YELLOW]
	var huds = [
		get_node("JogadorHud"),
		get_node("JogadorHud2"),
		get_node("JogadorHud3"),
		get_node("JogadorHud4")
	]
	
	for i in range(jogadores.size()):
		var jogador = jogadores[i]
		jogador.index = i
		jogador.nome = "Jogador %d" % (i + 1)
		
		if i < cores.size():
			jogador.set_cor(cores[i])
		
		if i < huds.size():
			var hud = huds[i]
			if hud != null:
				hud.setup(jogador.nome, cores[i])
				hud.atualizar_dinheiro(jogador.dinheiro)
				if not jogador.dinheiro_alterado.is_connected(hud.atualizar_dinheiro):
					jogador.dinheiro_alterado.connect(hud.atualizar_dinheiro)
	
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
				# O offset já é calculado no mover, mas aqui precisamos posicionar inicialmente
				# Vamos usar uma lógica similar ou apenas setar a posição base e deixar o mover ajustar depois?
				# Melhor setar com offset manual aqui também para garantir
				var offset = Vector2.ZERO
				match jogador.index:
					0: offset = Vector2(-30, -30)
					1: offset = Vector2(30, -30)
					2: offset = Vector2(-30, 30)
					3: offset = Vector2(30, 30)
				jogador.peao.position = ponto_partida.position + Vector2(200, 200) + offset
	
	print("O jogo começou! É a vez de %s." % jogador_atual.nome)
	atualizar_ui_construcao()

# Passa para o próximo jogador.
func proximo_jogador() -> void:
	turno_atual = (turno_atual + 1) % jogadores.size()
	jogador_atual = jogadores[turno_atual]
	print("\n--- Próximo turno! É a vez de %s. ---" % jogador_atual.nome)
	print("\n--- Próximo turno! É a vez de %s. ---" % jogador_atual.nome)
	atualizar_ui_construcao()
	
	if jogador_atual.preso:
		print("%s está preso. Mostrando opções de prisão." % jogador_atual.nome)
		botao_rolar_dados.visible = false
		exibir_popup_prisao()
	else:
		botao_rolar_dados.visible = true
		botao_rolar_dados.disabled = false
	
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
	botao_rolar_dados.disabled = true
	
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
	
	if dado1 and dado2:
		dado1.animar_para(dado1_valor, destino_dado1)
		dado2.animar_para(dado2_valor, destino_dado2)
		await get_tree().create_timer(2.8).timeout

	var passos = dado1_valor + dado2_valor
	print("%s rolou os dados: %d + %d = %d" % [jogador_atual.nome, dado1_valor, dado2_valor, passos])
	ultimo_resultado_dados = passos

	# 2. Lógica de Movimento (considerando prisão)
	if jogador_atual.preso:
		if dado1_valor == dado2_valor:
			print("Dupla! %s saiu da prisão!" % jogador_atual.nome)
			jogador_atual.sair_da_prisao()
			await jogador_atual.mover(passos, tabuleiro)
		else:
			print("Não tirou dupla. Continua preso.")
			jogador_atual.turnos_na_prisao += 1
			if jogador_atual.turnos_na_prisao >= 3:
				print("3 turnos na prisão. Pagando fiança forçada.")
				jogador_atual.pagar(50)
				jogador_atual.sair_da_prisao()
				await jogador_atual.mover(passos, tabuleiro)
			else:
				# Não move, apenas espera
				await get_tree().create_timer(1.0).timeout
	else:
		# Movimento normal
		await jogador_atual.mover(passos, tabuleiro)

	# 3. Obtém o espaço em que o jogador parou
	var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)

	# 4. Executa a ação daquele espaço
	if espaco_atual != null:
			espaco_atual.ao_parar(jogador_atual)

	# 5. Passa para o próximo turno e habilita UI
	if action_popup != null and action_popup.visible:
		pass
	else:
		proximo_jogador()

func _on_construir_casa_apertado() -> void:
	var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)
	if espaco_atual is Propriedade and espaco_atual.dono == jogador_atual:
		exibir_popup_construcao(espaco_atual)

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

# --- Lógica do Popup de Ação ---
var action_popup: ActionPopup

func setup_action_popup() -> void:
	var popup_scene = load("res://scenes/UI/action_popup.tscn")
	if popup_scene:
		action_popup = popup_scene.instantiate()
		add_child(action_popup)
		action_popup = popup_scene.instantiate()
		add_child(action_popup)

func exibir_popup_compra(propriedade: Propriedade) -> void:
	if action_popup == null:
		setup_action_popup()
	
	action_popup.clear_buttons()
	action_popup.set_text("Deseja comprar %s por R$ %d?" % [propriedade.nome, propriedade.preco])
	
	action_popup.add_button("Sim", func():
		print("Jogo: Confirmou compra de ", propriedade.nome)
		propriedade.comprar(jogador_atual)
		proximo_jogador()
	)
	
	action_popup.add_button("Não", func():
		print("Jogador recusou a compra.")
		proximo_jogador()
	)
	
	action_popup.show_popup()

func exibir_popup_construcao(propriedade: Propriedade) -> void:
	if action_popup == null:
		setup_action_popup()
		
	action_popup.clear_buttons()
	action_popup.set_text("Construir casa em %s por R$ %d?" % [propriedade.nome, propriedade.custo_casa])
	
	action_popup.add_button("Sim", func():
		propriedade.construir_casa()
		atualizar_ui_construcao()
	)
	
	action_popup.add_button("Cancelar", func():
		print("Construção cancelada.")
	)
	
	action_popup.show_popup()
