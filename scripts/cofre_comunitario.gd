# Espaço de Cofre Comunitário. O jogador tira uma carta com uma ação aleatória.
extends Espaco

class_name CofreComunitario

# Lista de possíveis ações (cartas).
var cartas = [
	{"descricao": "Erro do banco a seu favor. Receba R$200.", "tipo": "receber", "valor": 200},
	{"descricao": "Taxas médicas. Pague R$50.", "tipo": "pagar", "valor": 50},
	{"descricao": "Da venda de ações, você recebe R$50.", "tipo": "receber", "valor": 50},
	{"descricao": "Receba por seus serviços R$25.", "tipo": "receber", "valor": 25},
	{"descricao": "Aniversário do feriado. Receba R$100.", "tipo": "receber", "valor": 100},
	{"descricao": "Pague a conta do hospital: R$100.", "tipo": "pagar", "valor": 100},
	{"descricao": "Você herda R$100.", "tipo": "receber", "valor": 100}
]

func _ready() -> void:
	cartas.shuffle()

func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	
	if cartas.is_empty():
		_ready()

	var carta = cartas.pop_front()
	print("Cofre Comunitário! A carta diz: '%s'" % carta.descricao)
	
	executar_acao(jogador, carta)
	
	cartas.push_back(carta)

func executar_acao(jogador: Jogador, carta: Dictionary) -> void:
	match carta.tipo:
		"receber":
			jogador.receber(carta.valor)
		"pagar":
			jogador.pagar(carta.valor)
