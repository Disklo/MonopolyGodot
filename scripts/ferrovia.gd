# Define uma ferrovia, um tipo de propriedade especial.
extends Propriedade

class_name Ferrovia

# O aluguel base é para quando o dono possui apenas uma ferrovia.
# O aluguel aumenta com o número de ferrovias possuídas.
# Aluguel: 1 = 25, 2 = 50, 3 = 100, 4 = 200
@export var alugueis: Array[int] = [25, 50, 100, 200]

# Sobrescreve a função de cobrar aluguel da classe Propriedade.
func cobrar_aluguel(jogador: Jogador) -> void:
	# Verifica se o dono existe.
	if dono == null:
		return

	# Conta quantas ferrovias o dono possui.
	var num_ferrovias = 0
	for prop in dono.propriedades:
		# Verifica se a propriedade é do tipo Ferrovia.
		if prop is Ferrovia:
			num_ferrovias += 1
	
	# Calcula o aluguel com base no número de ferrovias.
	# O número de ferrovias - 1 será o índice no array de aluguéis.
	var aluguel_a_cobrar = alugueis[num_ferrovias - 1]
	
	print("%s possui %d ferrovia(s). O aluguel é de R$%d." % [dono.nome, num_ferrovias, aluguel_a_cobrar])
	
	# Cobra o jogador e paga o dono.
	jogador.pagar(aluguel_a_cobrar)
	dono.receber(aluguel_a_cobrar)
