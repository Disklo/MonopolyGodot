# Espaço de Cofre Comunitário. O jogador tira uma carta com uma ação aleatória.
extends Espaco

class_name CofreComunitario

@export var jogo: Jogo

# Lista de possíveis ações (cartas).

# Dicionario da carta de Cofre para descrever o que ela faz.
var cartas = [
	{
		"descricao": "Erro do banco a seu favor.\nReceba R$200.",
		"tipo": "receber",
		"valor": 200
	},
	{
		"descricao": "Receba R$50 de um presente de aniversário.",
		"tipo": "receber",
		"valor": 50
	},
	{
		"descricao": "Pague a conta do hospital\nPague R$100.",
		"tipo": "pagar",
		"valor": 100
	},
	{
		"descricao": "Pague taxa escolar de R$50.",
		"tipo": "pagar",
		"valor": 50
	},
	{
		"descricao": "Receba R$100 de seguro de vida vencido.",
		"tipo": "receber",
		"valor": 100
	},
	{
		"descricao": "Esta carta pode ser usada para sair da prisão.\nSaia da prisão",
		"tipo": "sair_da_prisao"
	}
]


func _ready() -> void:
	cartas.shuffle()

func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	
	if cartas.is_empty():
		_ready()

	var carta = cartas.pop_front()
	print("Cofre Comunitário! A carta diz: '%s'" % carta.descricao)
	
	mostrar_carta(carta, jogador)
	
	cartas.push_back(carta)

# Função para mostrar carta na tela
func mostrar_carta(carta: Dictionary, jogador: Jogador):
	# buscando o nó Jogo para ter acesso a Carta
	var jogo = get_tree().current_scene as Jogo
	
	if not jogo or not jogo.carta:
		print('ERRO: Jogo ou Carta não encontrados')
		return
	
	var instancia_carta = jogo.carta
	instancia_carta.configurar_carta(carta, "Cofre Comunitário")
	
	# Mostra a carta no jogo
	instancia_carta.mostrarCarta()
	
	# Conecta o sinal de fechar para executar a ação quando a carta for fechada
	# Desconecta primeiro para evitar múltiplas conexões
	if instancia_carta.carta_fechada.is_connected(executar_acao):
		instancia_carta.carta_fechada.disconnect(executar_acao)
	instancia_carta.carta_fechada.connect(func(): executar_acao(jogador, carta))
	
	# Aguarda a carta ser fechada antes de continuar
	await instancia_carta.carta_fechada
		
		
		
func executar_acao(jogador: Jogador, carta: Dictionary) -> void:
	var jogo = get_tree().current_scene as Jogo
	var tabuleiro = jogo.tabuleiro if jogo else null
	
	if not tabuleiro:
		print("ERRO: Tabuleiro não encontrado!")
		return
	
	match carta.tipo:
		"receber":
			# Receba dinheiro
			jogador.receber(carta.valor)
		
		"pagar":
			# Pague dinheiro
			jogador.pagar(carta.valor)
		
		"sair_da_prisao":
			# Esta carta pode ser guardada para sair da prisão
			# Por enquanto, apenas adiciona a carta à lista do jogador
			print("%s recebeu uma carta 'Sair da Prisão' (pode ser usada quando preso)" % jogador.nome)
			# TODO: Implementar sistema de cartas guardadas
			# Por enquanto, apenas informa que recebeu a carta
		
		"mover_e_receber":
			# Avance para uma posição e receba dinheiro
			jogador.mover_para_posicao(carta.posicao, tabuleiro)
			jogador.receber(carta.valor)
			# Executa a ação do espaço onde parou
			var espaco = tabuleiro.obter_espaco(carta.posicao)
			if espaco:
				espaco.ao_parar(jogador)
		
		"ir_para_propriedade":
			# Avance até uma propriedade específica
			jogador.mover_para_posicao(carta.posicao, tabuleiro)
			# Executa a ação do espaço onde parou
			var espaco = tabuleiro.obter_espaco(carta.posicao)
			if espaco:
				espaco.ao_parar(jogador)
		
		"ir_para_prisao":
			# Vá para a Prisão
			jogador.mover_para_posicao(carta.posicao, tabuleiro)
			# Executa a ação do espaço da prisão
			var espaco = tabuleiro.obter_espaco(carta.posicao)
			if espaco:
				espaco.ao_parar(jogador)
		
		"pagar_todos":
			# Pague a cada jogador
			if jogo:
				for outro_jogador in jogo.jogadores:
					if outro_jogador != jogador:
						jogador.pagar(carta.valor)
						outro_jogador.receber(carta.valor)
		
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
				jogador.pagar(total_pagar)
				print("Reparos: %d casas x R$%d + %d hotéis x R$%d = R$%d" % [total_casas, valor_casa, total_hoteis, valor_hotel, total_pagar])
			else:
				print("Você não possui construções para reparar.")
		
		_:
			print("Tipo de ação desconhecido: %s" % carta.get("tipo", ""))
