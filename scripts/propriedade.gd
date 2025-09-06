# Define uma propriedade, que é um tipo de Espaço comprável.
extends Espaco

class_name Propriedade

# Variáveis da propriedade, configuráveis no editor
@export var preco: int = 100
@export var aluguel_base: int = 10

# O jogador que é o dono dessa propriedade. Fica nulo se não tiver dono.
var dono: Jogador = null


# Sobrescreve a função da classe Espaco
func ao_parar(jogador: Jogador) -> void:
	# Chama a função original para imprimir a mensagem (opcional)
	super.ao_parar(jogador)

	if dono == null:
		# Se não tem dono, o jogador pode comprar
		# Aqui entrará a lógica para mostrar o menu de compra na UI
		print("Propriedade sem dono. %s pode comprar por %d." % [jogador.nome, preco])
		# Lógica de compra (simplificada por enquanto)
		comprar(jogador)

	elif dono == jogador:
		# Se o jogador já é o dono, não acontece nada
		print("Você parou na sua própria propriedade.")

	else:
		# Se tem dono e é outro jogador, cobra aluguel
		print("Propriedade de %s. %s paga aluguel." % [dono.nome, jogador.nome])
		cobrar_aluguel(jogador)


# Lógica para um jogador comprar a propriedade
func comprar(jogador: Jogador) -> void:
	if jogador.dinheiro >= preco:
		print("%s comprou %s" % [jogador.nome, nome])
		jogador.pagar(preco)
		dono = jogador
		jogador.comprar_propriedade(self)
	else:
		print("%s não tem dinheiro para comprar %s" % [jogador.nome, nome])


# Lógica para cobrar aluguel do jogador que parou aqui
func cobrar_aluguel(jogador: Jogador) -> void:
	jogador.pagar(aluguel_base)
	dono.receber(aluguel_base)
