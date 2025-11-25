# Script principal que gerencia o fluxo do jogo.
extends Node

class_name Jogo

@onready var dado1: Node2D = $Dado1
@onready var dado2: Node2D = $Dado2

@onready var carta: Carta = $Carta

# Referências aos nós da cena, configuráveis no editor
@export var tabuleiro: Tabuleiro
@export var jogadores: Array[Jogador]

# Variáveis para controlar o estado do jogo
var turno_atual: int = 0
var rodada_atual: int = 1
var jogador_atual: Jogador
var ultimo_resultado_dados: int = 0

# Limites do Banco
var total_casas_banco: int = 32
var total_hoteis_banco: int = 12

@onready var botao_construir_propriedades: Button = $botaoConstruirPropriedades
@onready var botao_rolar_dados: Button = $botaoRolarDados
@onready var botao_debug_construir: Button = $botaoDebugConstruir
@onready var botao_debug_monopolio: Button = $botaoDebugMonopolio
@onready var botao_debug_Menu: Button = $botaoDebugMenu


var botoes_debug: Array[Button] = []

func _ready() -> void:
	setup_ui_extras()
	iniciar_jogo()
	configurar_interface_debug()
	
	# Remove o botão antigo
	if botao_construir_propriedades:
		botao_construir_propriedades.visible = false
		botao_construir_propriedades.queue_free()

var label_turno: RichTextLabel

func setup_ui_extras() -> void:
	var font = load("res://assets/fonts/VCR_OSD_MONO_1.001.ttf")
	
	# Label Turno
	label_turno = RichTextLabel.new()
	label_turno.bbcode_enabled = true
	label_turno.position = Vector2(-300, -250)
	label_turno.size = Vector2(600, 50)
	if font:
		label_turno.add_theme_font_override("normal_font", font)
		label_turno.add_theme_font_size_override("normal_font_size", 40)
	add_child(label_turno)
	
	# Botão Gerenciar Propriedades
	var btn_gerenciar = Button.new()
	btn_gerenciar.text = "GERENCIAR\nPROPRIEDADES"
	btn_gerenciar.position = Vector2(-150, -150)
	btn_gerenciar.size = Vector2(300, 300)
	if font:
		btn_gerenciar.add_theme_font_override("font", font)
		btn_gerenciar.add_theme_font_size_override("font_size", 40)
	btn_gerenciar.pressed.connect(abrir_gerenciador_propriedades)
	add_child(btn_gerenciar)

	# Botão Negociar
	var btn_debug_dinheiro = Button.new()
	btn_debug_dinheiro.text = "+R$1000"
	btn_debug_dinheiro.position = Vector2(-311, -600)
	btn_debug_dinheiro.size = Vector2(200, 100)
	if font:
		btn_debug_dinheiro.add_theme_font_override("font", font)
		btn_debug_dinheiro.add_theme_font_size_override("font_size", 40)
	btn_debug_dinheiro.pressed.connect(func():
		if jogador_atual:
			jogador_atual.receber(1000)
			print("Debug: Adicionado R$1000 para %s" % jogador_atual.nome)
	)
	add_child(btn_debug_dinheiro)
	botoes_debug.append(btn_debug_dinheiro)
	btn_debug_dinheiro.visible = ConfiguracaoJogo.modo_debug

	var btn_debug_falencia = Button.new()
	btn_debug_falencia.text = "FALÊNCIA"
	btn_debug_falencia.position = Vector2(-311, -480)
	btn_debug_falencia.size = Vector2(200, 100)
	if font:
		btn_debug_falencia.add_theme_font_override("font", font)
		btn_debug_falencia.add_theme_font_size_override("font_size", 40)
	btn_debug_falencia.pressed.connect(func():
		if jogador_atual:
			print("Debug: Simulando falência para %s" % jogador_atual.nome)
			declarar_falencia(jogador_atual)
	)
	add_child(btn_debug_falencia)
	botoes_debug.append(btn_debug_falencia)
	btn_debug_falencia.visible = ConfiguracaoJogo.modo_debug
	
	# Botão Debug Sorte
	var btn_debug_sorte = Button.new()
	btn_debug_sorte.text = "SORTE"
	btn_debug_sorte.position = Vector2(-311, -360)
	btn_debug_sorte.size = Vector2(200, 100)
	if font:
		btn_debug_sorte.add_theme_font_override("font", font)
		btn_debug_sorte.add_theme_font_size_override("font_size", 40)
	btn_debug_sorte.pressed.connect(func():
		if jogador_atual:
			print("Debug: Testando carta de Sorte para %s" % jogador_atual.nome)
			_ao_pressionar_debug_sorte()
	)
	add_child(btn_debug_sorte)
	botoes_debug.append(btn_debug_sorte)
	btn_debug_sorte.visible = ConfiguracaoJogo.modo_debug
	
	# Botão Debug Cofre
	var btn_debug_cofre = Button.new()
	btn_debug_cofre.text = "COFRE"
	btn_debug_cofre.position = Vector2(-311, -240)
	btn_debug_cofre.size = Vector2(200, 100)
	if font:
		btn_debug_cofre.add_theme_font_override("font", font)
		btn_debug_cofre.add_theme_font_size_override("font_size", 40)
	btn_debug_cofre.pressed.connect(func():
		if jogador_atual:
			print("Debug: Testando carta de Cofre Comunitário para %s" % jogador_atual.nome)
			_ao_pressionar_debug_cofre()
	)
	add_child(btn_debug_cofre)
	botoes_debug.append(btn_debug_cofre)
	btn_debug_cofre.visible = ConfiguracaoJogo.modo_debug

	var btn_negociar = Button.new()
	btn_negociar.text = "NEGOCIAR"
	btn_negociar.position = Vector2(200, -150)
	btn_negociar.size = Vector2(300, 300)
	if font:
		btn_negociar.add_theme_font_override("font", font)
		btn_negociar.add_theme_font_size_override("font_size", 40)
	btn_negociar.pressed.connect(abrir_negociacao)
	add_child(btn_negociar)

func atualizar_label_turno() -> void:
	if label_turno and jogador_atual:
		label_turno.text = "[center][color=black]Turno do jogador %d [color=#%s]●[/color][/color][/center]" % [jogador_atual.index + 1, jogador_atual.cor.to_html()]

func configurar_interface_debug() -> void:
	if botao_debug_construir:
		botoes_debug.append(botao_debug_construir)
		botao_debug_construir.visible = ConfiguracaoJogo.modo_debug
	if botao_debug_monopolio:
		botoes_debug.append(botao_debug_monopolio)
		botao_debug_monopolio.visible = ConfiguracaoJogo.modo_debug
	if botao_debug_Menu:
		botoes_debug.append(botao_debug_Menu)
		botao_debug_Menu.visible = ConfiguracaoJogo.modo_debug

	var y_offset = 0
	for i in range(jogadores.size()):
		var jogador = jogadores[i]
		var btn = Button.new()
		btn.text = "Prender %s" % jogador.nome
		# Posiciona no canto superior direito, abaixo um do outro
		btn.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
		btn.size = Vector2(200, 40)
		btn.pressed.connect(func(): _ao_pressionar_debug_prender(jogador))
		add_child(btn)
		botoes_debug.append(btn)
		btn.visible = ConfiguracaoJogo.modo_debug
		y_offset += 50

	# Botões de Debug de Falência
	var btn_falencia_aluguel = Button.new()
	btn_falencia_aluguel.text = "Debug: Falência Aluguel"
	btn_falencia_aluguel.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
	btn_falencia_aluguel.size = Vector2(200, 40)
	btn_falencia_aluguel.pressed.connect(func():
		if jogador_atual:
			print("DEBUG: Simulando Falência por Aluguel")
			jogador_atual.dinheiro = 0
			jogador_atual.dinheiro_alterado.emit(0)
			# Move para uma propriedade cara (ex: última do tabuleiro)
			# Precisa garantir que tenha dono diferente.
			# Vamos pegar a propriedade 39 (Mayfair/Azul Escuro) e dar para outro jogador
			var prop = tabuleiro.obter_espaco(39)
			if prop is Propriedade:
				var outro_jogador = jogadores[(jogador_atual.index + 1) % jogadores.size()]
				prop.dono = outro_jogador
				outro_jogador.propriedades.append(prop)
				prop.num_casas = 5 # Hotel para garantir falência
				prop.aluguel_base = 2000 # Força valor alto
				jogador_atual.mover_para_posicao(39, tabuleiro)
				prop.ao_parar(jogador_atual)
	)
	add_child(btn_falencia_aluguel)
	botoes_debug.append(btn_falencia_aluguel)
	btn_falencia_aluguel.visible = ConfiguracaoJogo.modo_debug
	y_offset += 50

	var btn_falencia_imposto = Button.new()
	btn_falencia_imposto.text = "Debug: Falência Imposto"
	btn_falencia_imposto.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
	btn_falencia_imposto.size = Vector2(200, 40)
	btn_falencia_imposto.pressed.connect(func():
		if jogador_atual:
			print("DEBUG: Simulando Falência por Imposto")
			jogador_atual.dinheiro = 0
			jogador_atual.dinheiro_alterado.emit(0)
			# Move para Imposto de Renda (pos 4)
			jogador_atual.mover_para_posicao(4, tabuleiro)
			var imposto = tabuleiro.obter_espaco(4)
			if imposto:
				imposto.ao_parar(jogador_atual)
	)
	add_child(btn_falencia_imposto)
	botoes_debug.append(btn_falencia_imposto)
	btn_falencia_imposto.visible = ConfiguracaoJogo.modo_debug
	y_offset += 50

	# Novos Botões de Debug
	var btn_debug_dinheiro_0 = Button.new()
	btn_debug_dinheiro_0.text = "Debug: $0"
	btn_debug_dinheiro_0.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
	btn_debug_dinheiro_0.size = Vector2(200, 40)
	btn_debug_dinheiro_0.pressed.connect(func():
		if jogador_atual:
			print("DEBUG: Definindo dinheiro para 0")
			jogador_atual.dinheiro = 0
			jogador_atual.dinheiro_alterado.emit(0)
	)
	add_child(btn_debug_dinheiro_0)
	botoes_debug.append(btn_debug_dinheiro_0)
	btn_debug_dinheiro_0.visible = ConfiguracaoJogo.modo_debug
	y_offset += 50

	var btn_debug_dinheiro_50 = Button.new()
	btn_debug_dinheiro_50.text = "Debug: $50"
	btn_debug_dinheiro_50.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
	btn_debug_dinheiro_50.size = Vector2(200, 40)
	btn_debug_dinheiro_50.pressed.connect(func():
		if jogador_atual:
			print("DEBUG: Definindo dinheiro para 50")
			jogador_atual.dinheiro = 50
			jogador_atual.dinheiro_alterado.emit(50)
	)
	add_child(btn_debug_dinheiro_50)
	botoes_debug.append(btn_debug_dinheiro_50)
	btn_debug_dinheiro_50.visible = ConfiguracaoJogo.modo_debug
	y_offset += 50

	var btn_debug_prisao_3x = Button.new()
	btn_debug_prisao_3x.text = "Debug: Prisão 3x"
	btn_debug_prisao_3x.position = Vector2(get_viewport().get_visible_rect().size.x - 250, 50 + y_offset)
	btn_debug_prisao_3x.size = Vector2(200, 40)
	btn_debug_prisao_3x.pressed.connect(func():
		if jogador_atual:
			print("DEBUG: Simulando 3ª tentativa na prisão")
			_ao_pressionar_debug_prender(jogador_atual)
			jogador_atual.turnos_na_prisao = 2
			# Reabre o popup para atualizar o estado (opcional, mas bom para feedback visual)
			exibir_popup_prisao(jogador_atual)
	)
	add_child(btn_debug_prisao_3x)
	botoes_debug.append(btn_debug_prisao_3x)
	btn_debug_prisao_3x.visible = ConfiguracaoJogo.modo_debug
	y_offset += 50

func _ao_pressionar_debug_prender(jogador: Jogador) -> void:
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
		exibir_popup_prisao(jogador)

func _on_debug_voltar_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func exibir_popup_prisao(jogador: Jogador) -> void:
	if popup_acao == null:
		setup_popup_acao()
	
	popup_acao.clear_buttons()
	popup_acao.set_text("%s, você está preso! O que deseja fazer?" % jogador.nome)
	
	# Adiciona o botão de usar carta apenas se o jogador tiver a carta
	if jogador.tem_carta_sair_da_prisao():
		popup_acao.add_button("Usar Carta 'Sair da Prisão'", Callable(self, "_usar_carta_prisao").bind(jogador))
	
	popup_acao.add_button("Pagar Fiança (R$ 50)", func():
		if jogador.dinheiro >= 50:
			jogador.pagar(50)
			jogador.sair_da_prisao()
			botao_rolar_dados.visible = true
			botao_rolar_dados.disabled = false
			print('rolando dados.. Fiança')
			rolar_dados()
		else:
			print("Dinheiro insuficiente.")
			# Se não tem dinheiro, avisa e força os dados (se não for a 3ª vez, que já força pagamento)
			# Mas aqui é a escolha voluntária.
			exibir_popup_mensagem("Dinheiro insuficiente para pagar a fiança. Tentando sair nos dados...", func():
				rolar_dados()
			)
	)
	
	popup_acao.add_button("Tentar Dados", func():
		rolar_dados()
	)
	
	popup_acao.show_popup()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()

func _usar_carta_prisao(jogador: Jogador):
	if jogador.usar_carta_sair_da_prisao():
		jogador.sair_da_prisao()
		popup_acao.hide_popup()

		botao_rolar_dados.visible = true
		botao_rolar_dados.disabled = false

		print("Rolando dados Sair da Prisao")
		rolar_dados()
	else:
		exibir_popup_mensagem("Erro: Carta não encontrada.", func():
			exibir_popup_prisao(jogador)
		)

func exibir_popup_mensagem(texto: String, callback: Callable = Callable(), auto_confirm_bot: bool = true) -> void:
	print('entrando em exibir_popup_mensagem')
	if popup_acao == null:
		setup_popup_acao()
	
	popup_acao.clear_buttons()
	popup_acao.set_text(texto)
	
	popup_acao.add_button("OK", func():
		if not callback.is_null():
			callback.call()
	)
	
	popup_acao.show_popup()
	
	if jogador_atual and jogador_atual.is_bot and auto_confirm_bot:
		popup_acao.auto_select_random_option()

# Prepara o estado inicial do jogo.
func iniciar_jogo() -> void:
	# Adicionando referências dos nós.
	tabuleiro = get_node("Tabuleiro")
	
	jogadores.clear()
	# Adiciona todos os jogadores da cena
	for child in get_children():
		if child is Jogador:
			jogadores.append(child)
	
	var cores = [Color.BLUE, Color.DARK_RED, Color.DARK_GREEN, Color.DARK_GOLDENROD]
	var huds = [
		get_node("JogadorHud"),
		get_node("JogadorHud2"),
		get_node("JogadorHud3"),
		get_node("JogadorHud4")
	]
	
	for i in range(jogadores.size()):
		var jogador = jogadores[i]
		jogador.index = i
		
		# Configura tipo do jogador (Humano ou Computador)
		if i < ConfiguracaoJogo.numero_jogadores_humanos:
			jogador.tipo = Jogador.Tipo.HUMANO
			jogador.nome = "Jogador %d" % (i + 1)
		else:
			jogador.tipo = Jogador.Tipo.COMPUTADOR
			jogador.nome = "Computador %d" % (i + 1)
		
		if i < cores.size():
			jogador.set_cor(cores[i])
		
		if i < huds.size():
			var hud = huds[i]
			if hud != null:
				hud.setup(jogador.nome, cores[i])
				hud.atualizar_dinheiro(jogador.dinheiro)
				if not jogador.dinheiro_alterado.is_connected(hud.atualizar_dinheiro):
					jogador.dinheiro_alterado.connect(hud.atualizar_dinheiro)
					
	print("Configuração de jogadores:")
	for j in jogadores:
		print("- %s (%s)" % [j.nome, "Humano" if j.tipo == Jogador.Tipo.HUMANO else "Computador"])
	
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
				var offset = Vector2.ZERO
				jogador.peao.position = ponto_partida.position + Vector2(200, 200) + offset
				match jogador.index:
					0: offset = Vector2(-30, -30)
					1: offset = Vector2(30, -30)
					2: offset = Vector2(-30, 30)
					3: offset = Vector2(30, 30)
				jogador.peao.position = ponto_partida.position + Vector2(200, 200) + offset
	
	print("O jogo começou! É a vez de %s." % jogador_atual.nome)
	atualizar_ui_construcao()
	atualizar_label_turno()
	
	if jogador_atual.is_bot:
		print("Bot %s vai jogar (primeiro turno)..." % jogador_atual.nome)
		botao_rolar_dados.disabled = true
		call_deferred("_iniciar_turno_bot")

# Passa para o próximo jogador.
func proximo_jogador() -> void:
	turno_atual = (turno_atual + 1) % jogadores.size()
	jogador_atual = jogadores[turno_atual]
	
	# Esconde os dados do turno anterior
	if dado1: dado1.visible = false
	if dado2: dado2.visible = false
	
	# Pula jogadores falidos
	while jogador_atual.falido:
		turno_atual = (turno_atual + 1) % jogadores.size()
		jogador_atual = jogadores[turno_atual]
		
		var todos_falidos = true
		for j in jogadores:
			if not j.falido:
				todos_falidos = false
				break
		if todos_falidos:
			break
	print("\n--- Próximo turno! É a vez de %s. ---" % jogador_atual.nome)
	atualizar_ui_construcao()
	atualizar_label_turno()
	
	if jogador_atual.preso:
		print("%s está preso. Mostrando opções de prisão." % jogador_atual.nome)
		botao_rolar_dados.visible = false
		exibir_popup_prisao(jogador_atual)
	else:
		botao_rolar_dados.visible = true
		botao_rolar_dados.disabled = false
	
	atualizar_ui_construcao()
	atualizar_label_turno()

	if jogador_atual.is_bot:
		print("Bot %s vai jogar..." % jogador_atual.nome)
		botao_rolar_dados.disabled = true
		call_deferred("_iniciar_turno_bot")

func _iniciar_turno_bot() -> void:
	var bot_do_turno = jogador_atual
	await get_tree().create_timer(2.0).timeout
	
	if jogador_atual != bot_do_turno:
		return # O turno mudou enquanto esperava
		
	if jogador_atual.preso:
		# Bot preso: tenta sair (lógica simplificada: rola dados)
		# TODO: Melhorar lógica de prisão para bots (usar carta, pagar, etc)
		rolar_dados()
	else:
		rolar_dados()

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
	# botao_construir_propriedades.visible = false # Removido
	
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
	
	# Calcula a posição de destino dos dados obs: soma-se 300 para que eles não caem na mesma posição
	var destino_dado1 = Vector2(randi_range(-630.0, 820.0) + 300, randi_range(430.0, 675.0) + 300)
	var destino_dado2 = Vector2(randi_range(-630.0, 820.0) + 300, randi_range(430.0, 675.0) + 300)
	
	
	# Animação dos dados
	if dado1 and dado2:
		dado1.animar_para(dado1_valor, destino_dado1)
		dado2.animar_para(dado2_valor, destino_dado2)
		await get_tree().create_timer(2.8).timeout

	var passos = dado1_valor + dado2_valor
	print("%s rolou os dados: %d + %d = %d" % [jogador_atual.nome, dado1_valor, dado2_valor, passos])
	ultimo_resultado_dados = passos

	var should_process_space_action = false

	if jogador_atual.preso:
		if dado1_valor == dado2_valor:
			print("Dupla! %s saiu da prisão!" % jogador_atual.nome)
			jogador_atual.sair_da_prisao()
			await jogador_atual.mover(passos, tabuleiro)
			should_process_space_action = true
		else:
			print("Não tirou dupla. Continua preso.")
			jogador_atual.turnos_na_prisao += 1
			if jogador_atual.turnos_na_prisao >= 3:
				print("3 turnos na prisão. Pagamento de fiança obrigatório.")
				
				if verificar_falencia_obrigatoria(jogador_atual, 50):
					return # Faliu
				
				jogador_atual.pagar(50)
				jogador_atual.sair_da_prisao()
				await jogador_atual.mover(passos, tabuleiro)
				should_process_space_action = true
			else:
				await get_tree().create_timer(1.0).timeout
				proximo_jogador()
				return
	else:
		await jogador_atual.mover(passos, tabuleiro)
		should_process_space_action = true

	if should_process_space_action:
		var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)
		if espaco_atual != null:
			await espaco_atual.ao_parar(jogador_atual)

	if popup_acao != null and popup_acao.visible:
		pass
	else:
		proximo_jogador()

func _on_construir_propriedades_apertado() -> void:
	if jogador_atual == null:
		return
		
	var tem_monopolio = false
	for propriedade in jogador_atual.propriedades:
		if jogador_atual.tem_monopolio(propriedade.cor_grupo, tabuleiro):
			tem_monopolio = true
			break
	
	if not tem_monopolio:
		exibir_popup_mensagem("Você só pode construir um imóvel caso possua um monopólio de um grupo de cor.")
	else:
		for propriedade in jogador_atual.propriedades:
			if jogador_atual.tem_monopolio(propriedade.cor_grupo, tabuleiro):
				propriedade.toggle_botao_construir()

func atualizar_ui_construcao() -> void:
	# Botão antigo removido. Função mantida para compatibilidade.
	pass

func _ao_pressionar_debug_construir() -> void:
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

func _ao_pressionar_debug_monopolio() -> void:
	if popup_acao == null:
		setup_popup_acao()
	
	popup_acao.clear_buttons()
	popup_acao.set_text("Selecione o grupo de cor para obter monopólio:")
	
	var cores = ["marrom", "azul_claro", "rosa", "laranja", "vermelho", "amarelo", "verde", "azul_escuro"]
	var nomes_cores = ["Marrom", "Azul Claro", "Rosa", "Laranja", "Vermelho", "Amarelo", "Verde", "Azul Escuro"]
	
	for i in range(cores.size()):
		var cor = cores[i]
		var nome = nomes_cores[i]
		popup_acao.add_button(nome, func():
			dar_monopolio(cor)
			popup_acao.visible = false
		)
	
	popup_acao.add_button("Cancelar", func():
		popup_acao.visible = false
	)
	
	popup_acao.show_popup()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()

func dar_monopolio(cor_grupo: String) -> void:
	print("DEBUG: Dando monopólio de %s para %s" % [cor_grupo, jogador_atual.nome])
	for espaco in tabuleiro.espacos:
		if espaco is Propriedade and espaco.cor_grupo == cor_grupo:
			# Remove do dono anterior se houver
			if espaco.dono != null and espaco.dono != jogador_atual:
				espaco.dono.propriedades.erase(espaco)
			
			# Adiciona ao novo dono
			if espaco.dono != jogador_atual:
				espaco.dono = jogador_atual
				jogador_atual.propriedades.append(espaco)
				espaco.comprado = true
				espaco.lote_comprado()
				espaco.atualizar_indicador_dono()
	
	atualizar_ui_construcao()
	exibir_popup_mensagem("Monopólio de %s concedido a %s!" % [cor_grupo, jogador_atual.nome])

# --- Lógica do Popup de Ação ---
var popup_acao: PopupAcao
var gerenciador_propriedades: GerenciadorPropriedades
var leilao_ui: LeilaoUI
var negociacao_ui: NegociacaoUI
var seletor_cartas: SeletorCartas

func setup_popup_acao() -> void:
	var popup_scene = load("res://scenes/UI/popup_acao.tscn")
	if popup_scene:
		popup_acao = popup_scene.instantiate()
		add_child(popup_acao)
		
	var manager_scene = load("res://scenes/UI/gerenciador_propriedades.tscn")
	if manager_scene:
		gerenciador_propriedades = manager_scene.instantiate()
		add_child(gerenciador_propriedades)
		gerenciador_propriedades.setup(self)
		gerenciador_propriedades.hide()
		
	var leilao_scene = load("res://scenes/UI/leilao_ui.tscn")
	if leilao_scene:
		leilao_ui = leilao_scene.instantiate()
		add_child(leilao_ui)
		leilao_ui.setup(self)
		
	var negociacao_scene = load("res://scenes/UI/negociacao_ui.tscn")
	if negociacao_scene:
		negociacao_ui = negociacao_scene.instantiate()
		add_child(negociacao_ui)
		negociacao_ui.setup(self)
		
	var seletor_scene = load("res://scenes/UI/seletor_cartas.tscn")
	if seletor_scene:
		seletor_cartas = seletor_scene.instantiate()
		add_child(seletor_cartas)
		seletor_cartas.hide()

func abrir_gerenciador_propriedades() -> void:
	if gerenciador_propriedades == null:
		setup_popup_acao() # Garante que foi carregado
	
	if gerenciador_propriedades:
		gerenciador_propriedades.abrir(jogador_atual)

func abrir_negociacao() -> void:
	if negociacao_ui == null:
		setup_popup_acao()
		
	if negociacao_ui:
		negociacao_ui.abrir(jogador_atual)

func exibir_popup_confirmacao(texto: String, on_sim: Callable, on_nao: Callable = Callable(), texto_sim: String = "Sim", texto_nao: String = "Não") -> void:
	if popup_acao == null:
		setup_popup_acao()
	
	popup_acao.clear_buttons()
	popup_acao.set_text(texto)
	
	popup_acao.add_button(texto_sim, func():
		if not on_sim.is_null(): on_sim.call()
	)
	
	popup_acao.add_button(texto_nao, func():
		if not on_nao.is_null(): on_nao.call()
	)
	
	popup_acao.show_popup()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()

func verificar_falencia_obrigatoria(jogador: Jogador, valor: int) -> bool:
	if jogador.dinheiro < valor:
		print("FALÊNCIA AUTOMÁTICA: %s não tem R$ %d (Saldo: R$ %d)" % [jogador.nome, valor, jogador.dinheiro])
		declarar_falencia(jogador)
		return true
	return false

func exibir_popup_compra(propriedade: Propriedade, jogador: Jogador = null) -> void:
	if popup_acao == null:
		setup_popup_acao()
	
	# Se não foi passado jogador, usa jogador atual
	
	if jogador == null:
		jogador = jogador_atual
	
	popup_acao.clear_buttons()
	
	if jogador.dinheiro < propriedade.preco:
		popup_acao.set_text("%s, você não tem dinheiro suficiente (R$ %d) para comprar %s (R$ %d)." % [jogador.nome, jogador.dinheiro, propriedade.nome, propriedade.preco])
		popup_acao.add_button("OK", func():
			print("Dinheiro insuficiente. Iniciando leilão.")
			if leilao_ui == null:
				setup_popup_acao()
			if leilao_ui:
				leilao_ui.iniciar_leilao(propriedade, jogadores)
			else:
				proximo_jogador()
		)
	else:
		popup_acao.set_text("%s Deseja comprar %s por R$ %d?" % [jogador.nome, propriedade.nome, propriedade.preco])
		
		popup_acao.add_button("Sim", func():
			print("Jogo: Confirmou compra de ", propriedade.nome)
			propriedade.comprar(jogador_atual)
			proximo_jogador()
		)
		
		popup_acao.add_button("Não", func():
			print("%s recusou a compra. Iniciando leilão." % jogador.nome)
			# Inicia leilão
			if leilao_ui == null:
				setup_popup_acao()
			
			if leilao_ui:
				leilao_ui.iniciar_leilao(propriedade, jogadores)
			else:
				proximo_jogador() # Fallback
		)
	
	popup_acao.show_popup()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()

func exibir_popup_construcao(propriedade: Propriedade) -> void:
	if popup_acao == null:
		setup_popup_acao()
		
	popup_acao.clear_buttons()
	
	if jogador_atual.dinheiro < propriedade.custo_casa:
		popup_acao.set_text("Você não tem dinheiro suficiente (R$ %d) para construir em %s (Custo: R$ %d)." % [jogador_atual.dinheiro, propriedade.nome, propriedade.custo_casa])
		popup_acao.add_button("OK", func():
			popup_acao.hide_popup()
		)
	else:
		popup_acao.set_text("Construir casa em %s por R$ %d?" % [propriedade.nome, propriedade.custo_casa])
		
		popup_acao.add_button("Sim", func():
			propriedade.construir_casa()
			atualizar_ui_construcao()
		)
		
		popup_acao.add_button("Cancelar", func():
			print("Construção cancelada.")
		)
	
	popup_acao.show_popup()
	
	if jogador_atual and jogador_atual.is_bot:
		popup_acao.auto_select_random_option()

func declarar_falencia(jogador: Jogador, credor: Jogador = null) -> void:
	print("FALÊNCIA! %s declarou falência." % jogador.nome)
	jogador.falido = true
	
	jogador.dinheiro = 0
	jogador.dinheiro_alterado.emit(jogador.dinheiro)
	
	for prop in jogador.propriedades:
		if credor != null:
			prop.dono = credor
			credor.propriedades.append(prop)
			prop.atualizar_indicador_dono()
			
			if prop.hipotecada:
				var taxa = int((prop.preco / 2.0) * 0.1)
				credor.pagar(taxa)
				print("%s pagou taxa de %d pela propriedade hipotecada %s" % [credor.nome, taxa, prop.nome])
		else:
			prop.dono = null
			prop.comprado = false
			prop.hipotecada = false
			prop.num_casas = 0
			prop.lotevenda.visible = true
			prop.preco_label.visible = true
			prop.aluguel_label.visible = false
			prop.indicador_dono.visible = false
			# Leilão imediato (TODO)
	
	jogador.propriedades.clear()
	
	# Remove jogador visualmente
	jogador.peao.visible = false
	
	exibir_popup_mensagem("%s faliu e saiu do jogo!" % jogador.nome, func():
		if not verificar_fim_jogo():
			if jogador == jogador_atual:
				proximo_jogador()
	)

func verificar_fim_jogo() -> bool:
	var jogadores_ativos: Array[Jogador] = []
	for j in jogadores:
		if not j.falido:
			jogadores_ativos.append(j)
	
	if jogadores_ativos.size() == 1:
		var vencedor: Jogador = jogadores_ativos[0]
		exibir_popup_mensagem(
			"🏆 FIM DE JOGO!\n\nParabéns, %s!\nVocê venceu o jogo!" % vencedor.nome,
			func(): get_tree().change_scene_to_file("res://scenes/menu_principal.tscn"),
			false # auto_confirm_bot = false
			)
		return true
	return false

func _ao_pressionar_debug_sorte() -> void:
	if not jogador_atual or not tabuleiro:
		print("DEBUG: Jogador atual ou tabuleiro não encontrado")
		return
	
	# Procura o espaço de Sorte no tabuleiro
	var espaco_sorte: Sorte = null
	for espaco in tabuleiro.espacos:
		if espaco is Sorte:
			espaco_sorte = espaco
			break
	
	if not espaco_sorte:
		print("DEBUG: Espaço de Sorte não encontrado no tabuleiro")
		return
	
	# Configurar seletor de cartas
	if seletor_cartas == null:
		setup_popup_acao()
	
	seletor_cartas.abrir(
		"Selecione a carta de Sorte:",
		espaco_sorte.cartas,
		func(carta_selecionada: Dictionary):
			print("DEBUG: Carta de Sorte selecionada: %s" % carta_selecionada.descricao)
			await espaco_sorte.mostrar_carta(carta_selecionada, jogador_atual)
	)

func _ao_pressionar_debug_cofre() -> void:
	if not jogador_atual or not tabuleiro:
		print("DEBUG: Jogador atual ou tabuleiro não encontrado")
		return
	
	# Procura o espaço de Cofre Comunitário no tabuleiro
	var espaco_cofre: CofreComunitario = null
	for espaco in tabuleiro.espacos:
		if espaco is CofreComunitario:
			espaco_cofre = espaco
			break
	
	if not espaco_cofre:
		print("DEBUG: Espaço de Cofre Comunitário não encontrado no tabuleiro")
		return
	
	# Configurar seletor de cartas
	if seletor_cartas == null:
		setup_popup_acao()
	
	seletor_cartas.abrir(
		"Selecione a carta de Cofre Comunitário:",
		espaco_cofre.cartas,
		func(carta_selecionada: Dictionary):
			print("DEBUG: Carta de Cofre selecionada: %s" % carta_selecionada.descricao)
			await espaco_cofre.mostrar_carta(carta_selecionada, jogador_atual)
	)
func _on_botao_debug_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
