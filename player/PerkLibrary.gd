extends Node

var All: Array[Perk.Definition] = []
var Available: Array[Perk.Definition]:
	get:
		var player := GlobalContext.GetPlayer()
		return All.filter(func(perk: Perk.Definition) -> bool:
			return perk.isAvailable(player)
		)

func _ready() -> void:
	await get_tree().process_frame
	scanDirectory("res://player/perks")

func scanDirectory(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return

	dir.list_dir_begin()
	var fileName := dir.get_next()

	while fileName != "":
		if dir.current_is_dir():
			scanDirectory(path.path_join(fileName))
		elif isScriptFile(fileName):
			tryRegister(path.path_join(fileName))
		fileName = dir.get_next()

	dir.list_dir_end()

func isScriptFile(fileName: String) -> bool:
	return fileName.ends_with(".gd") or fileName.ends_with(".gdc")

func tryRegister(filePath: String) -> void:
	var script := load(filePath) as GDScript
	if not script or script.get_global_name() == &"Perk":
		return

	var baseType := script
	while baseType:
		if baseType.get_global_name() == &"Perk":
			register(script, script.Build())
			return
		baseType = baseType.get_base_script()

func register(script: GDScript, perk: Perk.Definition) -> void:
	if not perk.implementation:
		perk = perk.ImplementedBy(script)
	All.append(perk)
