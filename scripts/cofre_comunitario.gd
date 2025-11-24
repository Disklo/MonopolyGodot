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
		"descricao": "Saia da prisão gratuitamente",
		"tipo": "sair_da_prisao"
	},
	{
		"descricao": "Pague uma conta de luz atrasada\nPague R$300",
		"tipo": "pagar",
		"valor": 300
	},
	{
		"descricao": "Pague uma conta de água atrasada\nPague R$300",
		"tipo": "pagar",
		"valor": 300
	},
	{
		"descricao": "Pague a manutenção do seu carro\nPague R$500",
		"tipo": "pagar",
		"valor": 500
	},
	{
		"descricao": "Feliz natal! -- Receba R$50 de cada jogador",
		"tipo": "receber_de_todos",
		"valor": 50
	},
	{
		"descricao": "Reembolso do Imposto de Renda -- Receba R$20",
		"tipo": "receber",
		"valor": 20
	},
	{
		"descricao": "É Seu Aniversário -- Receba R$10 de cada jogador",
		"tipo": "receber_de_todos",
		"valor": 10
	},
	{
		"descricao": "Seguro de Vida Vencido -- Receba R$100",
		"tipo": "receber",
		"valor": 100
	},
	{
		"descricao": "Receba R$25 em Taxas de Consultoria",
		"tipo": "receber",
		"valor": 25
	},
	{
		"descricao": "Você Herda R$100",
		"tipo": "receber",
		"valor": 100
	},
	{
		"descricao": "Fundo de Férias/Fundo de Natal Vencido -- Receba R$100",
		"tipo": "receber",
		"valor": 100
	}
]


func _ready() -> void:
	cartas.shuffle()
	pass

func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	
	if cartas.is_empty():
		_ready()

	var carta = cartas.pop_front()
	print("Cofre Comunitário! A carta diz: '%s'" % carta.descricao)
	
	await mostrar_carta(carta, jogador)
	
	cartas.push_back(carta)

# Função para mostrar carta na tela
func mostrar_carta(carta: Dictionary, jogador: Jogador):
	# buscando o nó Jogo para ter acesso a Carta
	var jogo = get_tree().current_scene as Jogo
	
	if not jogo or not jogo.carta:
		print('ERRO: Jogo ou Carta não encontrados')
		return
	
	var instancia_carta = jogo.carta
	
	# Verifica se é uma carta que pode ser guardada
	var texto_botao = "Continuar"
	if carta.get("tipo") == "sair_da_prisao":
		texto_botao = "Guardar carta"
	
	# Configura a carta com o texto do botão apropriado
	instancia_carta.configurar_carta(carta, "Cofre Comunitário", texto_botao)
	
	# Mostra a carta no jogo
	instancia_carta.mostrarCarta()
	
	# Se for carta de sair da prisão, guarda ao invés de executar
	if carta.get("tipo") == "sair_da_prisao":
		instancia_carta.carta_fechada.connect(func(): guardar_carta_sair_da_prisao(jogador, carta), CONNECT_ONE_SHOT)
	else:
		instancia_carta.carta_fechada.connect(func(): executar_acao(jogador, carta))
	
	# Aguarda a carta ser fechada antes de continuar
	await instancia_carta.carta_fechada


# Função para guardar a carta de sair da prisão
func guardar_carta_sair_da_prisao(jogador: Jogador, carta: Dictionary) -> void:
	jogador.guardar_carta(carta)
	print("%s guardou a carta 'Sair da Prisão' para uso futuro" % jogador.nome)


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
			jogador.ir_para_prisao()
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
		"receber_de_todos":
			# Pague a cada jogador
			if jogo:
				for outro_jogador in jogo.jogadores:
					if outro_jogador != jogador:
						outro_jogador.pagar(carta.valor)
						jogador.receber(carta.valor)
		
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
