# Espaço de Sorte. O jogador tira uma carta com uma ação aleatória.
extends Espaco

class_name Sorte

# Lista de possíveis ações (cartas).
# Usaremos um dicionário para descrever a ação e o que ela faz.
var cartas = [
	{"descricao": "Avance para o Ponto de Partida. Receba R$200.", "tipo": "mover_e_receber", "posicao": 0, "valor": 200},
	{"descricao": "Vá para a Prisão, sem passar pelo Ponto de Partida.", "tipo": "mover", "posicao": 10},
	{"descricao": "O banco paga a você um dividendo de R$50.", "tipo": "receber", "valor": 50},
	{"descricao": "Pague uma multa de R$15 por excesso de velocidade.", "tipo": "pagar", "valor": 15},
	{"descricao": "Você foi eleito o presidente do conselho. Pague a cada jogador R$50.", "tipo": "pagar_todos", "valor": 50},
	{"descricao": "Seu empréstimo de construção venceu. Receba R$150.", "tipo": "receber", "valor": 150}
]

# Referência ao nó do jogo para obter a lista de jogadores.
@export var jogo: Jogo

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
	
	# Executa a ação da carta.
	executar_acao(jogador, carta)
	
	# Coloca a carta de volta no final do baralho.
	cartas.push_back(carta)

func executar_acao(jogador: Jogador, carta: Dictionary) -> void:
	match carta.tipo:
		"mover_e_receber":
			jogador.posicao = carta.posicao
			jogador.receber(carta.valor)
		"mover":
			jogador.posicao = carta.posicao
		"receber":
			jogador.receber(carta.valor)
		"pagar":
			jogador.pagar(carta.valor)
		"pagar_todos":
			if jogo:
				for outro_jogador in jogo.jogadores:
					if outro_jogador != jogador:
						jogador.pagar(carta.valor)
						outro_jogador.receber(carta.valor)
