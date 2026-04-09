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
	var danceFloor := GlobalContext.GetDanceFloor()
	if not danceFloor:
		return
	scanDirectory("res://player/perks")

func scanDirectory(path: String) -> void:
	for entry in ResourceLoader.list_directory(path):
		var fullPath := path.path_join(entry)
		if entry.ends_with("/"):
			scanDirectory(fullPath.trim_suffix("/"))
		elif isScriptFile(entry):
			tryRegister(fullPath)

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
