# Espaço de Sorte. O jogador tira uma carta com uma ação aleatória.
extends Espaco

class_name Sorte


# Lista de possíveis ações (cartas).
# Dicionario para a de carta de Sorte e descrever o que ela faz.

var cartas = [
	{"descricao": "Avance para o Ponto de Partida.\nReceba R$200.", "tipo": "mover_e_receber", "posicao": 0, "valor": 200},
	{"descricao": "Avance até a Avenida Amaral Peixoto.", "tipo": "ir_para_propriedade", "posicao": 8},
	{"descricao": "Avance até a Rua da Conceição", "tipo": "ir_para_propriedade", "posicao": 16},
	{"descricao": "Avance até a Companhia Elétrica", "tipo": "mover_para_companhia", "posicao": 12},
	{"descricao": "Avance até a Companhia de Água", "tipo": "mover_para_companhia", "posicao": 28},
	{"descricao": "Receba R$50 do banco.", "tipo": "receber", "valor": 50},
	{"descricao": "O banco paga a você dividendos de R$50.", "tipo": "receber", "valor": 50},
	{"descricao": "Vá para a Prisão sem passar pelo Ponto de Partida.", "tipo": "ir_para_prisao", "posicao": 10},
	{"descricao": "Vá para a Rua Ator Paulo Gustavo.", "tipo": "ir_para_propriedade", "posicao": 1},
	{"descricao": "Vá para a Rua Dr. Nilo Peçanha", "tipo": "ir_para_propriedade", "posicao": 34},
	{"descricao": "Você foi multado a pagar R$100 por velocidades acima do permitido.", "tipo": "pagar", "valor": 100},
	{"descricao": "Pague R$25 por cada casa e R$100 por cada hotel que possuir.", "tipo": "reparos", "valor_casa": 25, "valor_hotel": 100},
	{"descricao": "Faça reparos em todas as suas construções: R$40 por casa e R$115 por hotel.", "tipo": "reparos", "valor_casa": 40, "valor_hotel": 115},
	{"descricao": "Receba R$150 por venda de ações.", "tipo": "receber", "valor": 150},
	{"descricao": "Você ganhou o concurso de beleza.\nReceba R$50.", "tipo": "receber", "valor": 50},
	{"descricao": "Você recebeu um reembolso de imposto de renda.\nReceba R$60.", "tipo": "receber", "valor": 60},
	{"descricao": "Pague a cada jogador R$50.", "tipo": "pagar_todos", "valor": 50},
	{
		"descricao": "Avance para a Ferrovia mais próxima.",
		"tipo": "mover_para_ferrovia"
	},
	{
		"descricao": "Avance para a Companhia de Água mais próxima.",
		"tipo": "mover_para_companhia_mais_proxima"
	},
	{
		"descricao": "Saia da prisão gratuitamente",
		"tipo": "sair_da_prisao"
	},
	{
		"descricao": "Volte Três Casas",
		"tipo": "mover_casas",
		"valor": - 3
	},
	{
		"descricao": "Pague Imposto de Pobreza de R$15",
		"tipo": "pagar",
		"valor": 15
	}
]

# Referência ao nó do jogo para obter a lista de jogadores.
@export var jogo: Jogo
@onready var prisao: EnviaPrisao = $"../EnviaPrisao"


func _ready() -> void:
	# Embaralha as cartas no início do jogo.
	cartas.shuffle()
	
	
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	
	if cartas.is_empty():
		print("As cartas de Sorte acabaram. Embaralhando novamente.")
		_ready() # Re-embaralha se acabarem

	# Pega a primeira carta do baralho.
	var carta = cartas.pop_front()
	print("Sorte! A carta diz: '%s'" % carta.descricao)
	
	# Mostrar a carta antes de executar a ação
	await mostrar_carta(carta, jogador)
	
	# Coloca a carta de volta no final do baralho.
	cartas.push_back(carta)

# função para mostrar a carta na tela
func mostrar_carta(carta: Dictionary, jogador: Jogador) -> void:
	# buscando o nó Jogo para ter acesso a Carta
	var jogo = get_tree().current_scene as Jogo
	
	# Verifica se o jogo e a carta existem
	if not jogo or not jogo.carta:
		print("ERRO: Jogo ou Carta não encontrados!")
		return
	
	var instancia_carta = jogo.carta
	
	# Verifica se é uma carta que pode ser guardada
	var texto_botao = "Continuar"
	if carta.get("tipo") == "sair_da_prisao":
		texto_botao = "Guardar carta"
	
	# Configurar a carta com os dados
	instancia_carta.configurar_carta(carta, "Sorte", texto_botao)
	
	# Mostra a carta (pausa o jogo)
	instancia_carta.mostrarCarta()
	
	# Se for carta de sair da prisão, guarda ao invés de executar
	if carta.get("tipo") == "sair_da_prisao":
		instancia_carta.carta_fechada.connect(func(): guardar_carta_sair_da_prisao(jogador, carta), CONNECT_ONE_SHOT)
	else:
		# Conecta o sinal de fechar carta para executar a ação do jogador quando a carta for fechada
		# Desconecta primeiro para evitar múltiplas conexões
		if instancia_carta.carta_fechada.is_connected(executar_acao):
			instancia_carta.carta_fechada.disconnect(executar_acao)
		instancia_carta.carta_fechada.connect(func(): executar_acao(jogador, carta))
	
	# Aguarda a carta ser fechada antes de continuar
	if jogador.is_bot:
		await get_tree().create_timer(1.5).timeout
		instancia_carta.fecharCarta()
	else:
		await instancia_carta.carta_fechada

# Função para guardar a carta de sair da prisão
func guardar_carta_sair_da_prisao(jogador: Jogador, carta: Dictionary) -> void:
	jogador.guardar_carta(carta)
	print("%s guardou a carta 'Sair da Prisão' para uso futuro" % jogador.nome)

func executar_acao(jogador: Jogador, carta: Dictionary) -> void:
	var jogo = get_tree().current_scene
	var tabuleiro = jogo.tabuleiro if jogo else null
	
	if not tabuleiro:
		print('ERRO: Tabuleiro não encontrado')
	
	
	match carta.tipo:
		"mover_e_receber":
			# Mover para o Ponto de partida. Receba 200
			jogador.mover_para_posicao(carta.posicao, tabuleiro)
			jogador.receber(carta.valor)
			
		"ir_para_propriedade":
			# Avançar até uma propriedade especifica
			jogador.mover_para_posicao(carta.posicao, tabuleiro)
			# Executar ação do espaço onde parou
			var espaco = tabuleiro.obter_espaco(carta.posicao)
			if espaco:
				espaco.ao_parar(jogador)
				
				
		"mover_para_companhia":
			# A posição já está definida na carta
			jogador.mover_para_posicao(carta.posicao, tabuleiro)
			# Executa a ação do espaço onde parou (pode cobrar aluguel se tiver dono)
			var espaco = tabuleiro.obter_espaco(carta.posicao)
			if espaco:
				espaco.ao_parar(jogador)

		"mover_para_ferrovia":
			var pos_atual = jogador.posicao
			var ferrovias = [5, 15, 25, 35]
			var distancias = []
			for f in ferrovias:
				var d = f - pos_atual
				if d < 0:
					d += 40
				distancias.append(d)
			
			var menor_distancia = distancias[0]
			var ferrovia_proxima_idx = 0
			for i in range(1, distancias.size()):
				if distancias[i] < menor_distancia:
					menor_distancia = distancias[i]
					ferrovia_proxima_idx = i

			var ferrovia_proxima_pos = ferrovias[ferrovia_proxima_idx]
			jogador.mover_para_posicao(ferrovia_proxima_pos, tabuleiro)
			var espaco = tabuleiro.obter_espaco(ferrovia_proxima_pos)
			if espaco and espaco.dono and espaco.dono != jogador:
				# Pague ao proprietário 2x o aluguel
				var num_ferrovias = 0
				for prop in espaco.dono.propriedades:
					if prop is Ferrovia:
						num_ferrovias += 1
				var aluguel = espaco.alugueis[num_ferrovias - 1] * 2
				jogador.pagar(aluguel)
				espaco.dono.receber(aluguel)
			elif espaco:
				espaco.ao_parar(jogador)

		"mover_para_companhia_mais_proxima":
			var pos_atual = jogador.posicao
			var companhias = [12, 28]
			var distancias = []
			for c in companhias:
				var d = c - pos_atual
				if d < 0:
					d += 40
				distancias.append(d)
			
			var menor_distancia = distancias[0]
			var companhia_proxima_idx = 0
			for i in range(1, distancias.size()):
				if distancias[i] < menor_distancia:
					menor_distancia = distancias[i]
					companhia_proxima_idx = i

			var companhia_proxima_pos = companhias[companhia_proxima_idx]
			jogador.mover_para_posicao(companhia_proxima_pos, tabuleiro)
			var espaco = tabuleiro.obter_espaco(companhia_proxima_pos)
			if espaco and espaco.dono and espaco.dono != jogador:
				var aluguel = jogo.ultimo_resultado_dados * 10
				jogador.pagar(aluguel)
				espaco.dono.receber(aluguel)
			elif espaco:
				espaco.ao_parar(jogador)
		
		"mover_casas":
			await jogador.mover(carta.valor, tabuleiro)
			var espaco_atual = tabuleiro.obter_espaco(jogador.posicao)
			if espaco_atual != null:
				await espaco_atual.ao_parar(jogador)

		"ir_para_prisao":
			# Enviando para a prisão
			prisao.ao_parar(jogador)

		"receber":
			# Receba dinheiro
			jogador.receber(carta.valor)
		"pagar":
			# Pague dinheiro
			if jogo.has_method("verificar_falencia_obrigatoria"):
				if jogo.verificar_falencia_obrigatoria(jogador, carta.valor):
					return
			jogador.pagar(carta.valor)
			
		"pagar_todos":
			# Pague a cada jogador
			if jogo:
				var total_a_pagar = (jogo.jogadores.size() - 1) * carta.valor
				if jogo.has_method("verificar_falencia_obrigatoria"):
					if jogo.verificar_falencia_obrigatoria(jogador, total_a_pagar):
						return

				for outro_jogador in jogo.jogadores:
					if outro_jogador != jogador:
						jogador.pagar(carta.valor)
						outro_jogador.receber(carta.valor)
						print('pagando aos jogadores')
						
		"reparos":
			# Pague por cada casa e hotel
			var total_casas = 0
			var total_hoteis = 0
			
			for propriedade in jogador.propriedades:
				if propriedade.num_casas < 5:
					total_casas += propriedade.num_casas
				elif propriedade.num_casas == 5:
					total_hoteis += 1
			
			var valor_casa = carta.get("valor_casa", 0)
			var valor_hotel = carta.get("valor_hotel", 0)
			var total_pagar = (total_casas * valor_casa) + (total_hoteis * valor_hotel)
			
			if total_pagar > 0:
				if jogo.has_method("verificar_falencia_obrigatoria"):
					if jogo.verificar_falencia_obrigatoria(jogador, total_pagar):
						return
				jogador.pagar(total_pagar)
				print("Reparos: %d casas x R$%d + %d hotéis x R$%d = R$%d" % [total_casas, valor_casa, total_hoteis, valor_hotel, total_pagar])
			else:
				print("Você não possui construções para reparar.")
				
				
		_:
			print("Tipo de ação desconhecido: %s" % carta.get("tipo", ""))
