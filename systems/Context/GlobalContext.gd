extends Node

var registeredNodes: Array[Node]

func Register(node: Node) -> void:
	Unregister(node.get_script().get_global_name())
	registeredNodes.append(node)

func Find(type: GDScript) -> Node:
	var found := registeredNodes.filter(func(n: Node) -> bool: return is_instance_of(n, type))
	return found[0]
	
func Unregister(nodeName: String) -> void:
	for i in range(registeredNodes.size() - 1, -1, -1):
		if not is_instance_valid(registeredNodes[i]) or registeredNodes[i].get_script().get_global_name() == nodeName:
			registeredNodes.remove_at(i)

func GetPlayer() -> Player:
	return Find(Player)
	
func GetBoss() -> Boss:
	return Find(Boss)
	
func GetAudioAgent() -> AudioAgent:
	return Find(AudioAgent)

func GetDanceFloor() -> DanceFloor:
	return Find(DanceFloor)
