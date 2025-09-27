# Espaço de estacionamento livre. Geralmente, nada acontece aqui.
extends Espaco

class_name Estacionamento

# Sobrescreve a função da classe Espaco.
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	print("%s está descansando no Estacionamento Livre." % jogador.nome)
	# Em algumas regras da casa, o dinheiro dos impostos se acumula aqui,
	# mas vamos manter a regra padrão onde nada acontece.
	pass
