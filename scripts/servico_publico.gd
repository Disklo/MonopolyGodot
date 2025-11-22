# Define um serviço público (ex: Companhia de Água, Eletricidade).
# AGORA NÃO É MAIS COMPRÁVEL. O jogador paga ao banco.
extends Espaco

class_name ServicoPublico

# Multiplicadores para o cálculo do valor a pagar.
@export var multiplicador: int = 4 # Valor padrão se não houver lógica de "quantidade de serviços"

# Referência ao nó do jogo para obter o valor dos dados.
var jogo: Jogo

func _ready() -> void:
	super._ready()
	# Tenta encontrar o nó Jogo na raiz
	var root = get_tree().root
	if root.has_node("Jogo"):
		jogo = root.get_node("Jogo")

# Sobrescreve a função da classe Espaco.
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	
	if jogo == null:
		print("ERRO: Referência ao Jogo não encontrada em ServicoPublico.")
		return

	# O valor dos dados é pego da variável no script do jogo.
	var valor_dados = jogo.ultimo_resultado_dados
	
	# Regra simplificada: Paga 4x o valor dos dados ao banco.
	# Se quiséssemos implementar a regra de "10x se tiver os dois",
	# precisaríamos saber se o jogador caiu no outro serviço, mas como não tem dono,
	# a regra geralmente é fixa ou baseada em sorte.
	# Vamos manter 4x o valor dos dados por enquanto, pago ao banco.
	
	var valor_a_pagar = valor_dados * multiplicador
	
	print("Serviço Público! O jogador %s tirou %d nos dados. Paga %d * %d = R$%d ao banco." % [jogador.nome, valor_dados, multiplicador, valor_a_pagar])
	
	jogador.pagar(valor_a_pagar)
