# O jogador paga uma quantia fixa de imposto.
extends Espaco

class_name Imposto

# Valor do imposto a ser pago.
@export var valor_imposto: int = 200

# Sobrescreve a função da classe Espaco.
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	print("%s pagou R$%d de imposto." % [jogador.nome, valor_imposto])
	jogador.pagar(valor_imposto)
