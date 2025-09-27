# Define um serviço público (ex: Companhia de Água, Eletricidade).
extends Propriedade

class_name ServicoPublico

# Multiplicadores para o cálculo do aluguel.
@export var multiplicador_um_servico: int = 4
@export var multiplicador_dois_servicos: int = 10

# Referência ao nó do jogo para obter o valor dos dados.
# Isso precisa ser conectado na cena.
@export var jogo: Jogo

# Sobrescreve a função de cobrar aluguel.
func cobrar_aluguel(jogador: Jogador) -> void:
	if dono == null or jogo == null:
		return

	# Conta quantos serviços públicos o dono possui.
	var num_servicos = 0
	for prop in dono.propriedades:
		if prop is ServicoPublico:
			num_servicos += 1
	
	var multiplicador = 0
	if num_servicos == 1:
		multiplicador = multiplicador_um_servico
	elif num_servicos >= 2:
		multiplicador = multiplicador_dois_servicos
	
	# O valor dos dados é pego da variável no script do jogo.
	var valor_dados = jogo.ultimo_resultado_dados
	var aluguel_a_cobrar = valor_dados * multiplicador
	
	print("%s possui %d serviço(s). O aluguel é %d (dados) * %d = R$%d." % [dono.nome, num_servicos, valor_dados, multiplicador, aluguel_a_cobrar])
	
	jogador.pagar(aluguel_a_cobrar)
	dono.receber(aluguel_a_cobrar)
