@tool
extends Node

var registeredNodes: Array[Node]

func Register(node: Node) -> void:
	Unregister(node.get_script().get_global_name())
	registeredNodes.append(node)

func find(type: GDScript) -> Node:
	var found := registeredNodes.filter(func(n: Node) -> bool: return is_instance_of(n, type))
	if found.size() > 0:
		return found[0]
	return null

func Unregister(nodeName: String) -> void:
	for i in range(registeredNodes.size() - 1, -1, -1):
		if not is_instance_valid(registeredNodes[i]) or registeredNodes[i].get_script().get_global_name() == nodeName:
			registeredNodes.remove_at(i)

func GetPlayer() -> Player:
	return find(Player)

func GetBoss() -> Boss:
	return find(Boss)

func GetAudioAgent() -> AudioAgent:
	return find(AudioAgent)

func GetDanceFloor() -> DanceFloor:
	return find(DanceFloor)
