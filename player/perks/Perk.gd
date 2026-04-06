class_name Perk extends Node

@onready var perkManager: PlayerPerkManager = get_parent()
@onready var player: Player = perkManager.player

var definition: Definition

func _ready() -> void:
	if not definition:
		printerr("PlayerPerk created without definition class!")
		return

	for abilityClass: GDScript in definition.abilities:
		var ability: Ability = abilityClass.new()
		player.abilityController.add_child(ability)

func addAbility(ability: GDScript) -> void:
	var instance := Asset.Instantiate(ability) as Ability
	player.add_child(instance)

func removeAbility(ability: GDScript) -> void:
	var childrenToDelete: Array[Ability]
	for child: Node in player.get_children():
		if is_instance_of(child, ability):
			childrenToDelete.append(child)

	for child: Ability in childrenToDelete:
		player.remove_child(child)

enum Rarity {
	None = 0,
	Common = 1,
	Rare = 2,
	Epic = 3,
	Legendary = 4,
	Unique = 5
}

class Definition:
	var rarity: Rarity
	var perkName: String
	var perkDescription: String
	var maxLevel: int = 1
	var implementation: GDScript
	var abilities: Array[GDScript]
	var requiresAbilities: Array[GDScript]
	var requiresPerks: Array[Array] # Array[Array[GDScript]]

	func SetRarity(value: Rarity) -> Definition:
		rarity = value
		return self

	func Name(value: String) -> Definition:
		perkName = value
		return self

	func Description(value: String) -> Definition:
		if perkDescription:
			perkDescription += "\n" + value
		else:
			perkDescription = value
		return self

	func MaxLevel(value: int) -> Definition:
		maxLevel = value
		return self

	func ImplementedBy(implClass: GDScript) -> Definition:
		implementation = implClass
		return self

	func ProvidesAbility(ability: GDScript) -> Definition:
		abilities.append(ability)
		return self

	func RequiresAbility(ability: GDScript) -> Definition:
		requiresAbilities.append(ability)
		return self

	func RequiresPerk(perk: GDScript) -> Definition:
		requiresPerks.append([perk])
		return self

	func RequiresAnyPerk(perks: Array[GDScript]) -> Definition:
		requiresPerks.append(perks as Array)
		return self

	func InstantiateForPlayer() -> Perk:
		var instance: Perk
		var forPlayer := GlobalContext.GetPlayer()
		if implementation:
			instance = implementation.new()
		else:
			instance = Perk.new()
		instance.definition = self
		forPlayer.perkManager.Add(instance)
		return instance

static func Build() -> Definition:
	return Definition.new()
