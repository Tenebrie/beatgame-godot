extends Node

var registeredNodes: Array[Node]

func Register(node: Node) -> void:
	var nodeName := node.get_script().get_global_name() as String
	var nodeAlreadyExists := registeredNodes.any(
		func (n: Node) -> bool:
			return n.get_script().get_global_name() == nodeName
	)
	assert(!nodeAlreadyExists, "Node is already registered")
	registeredNodes.append(node)

func Find(type: GDScript) -> Node:
	var found := registeredNodes.filter(func(n: Node) -> bool: return is_instance_of(n, type))
	assert(found.size() == 1, "Expected exactly one " + str(type))
	return found[0]

func GetPlayer() -> Player:
	return Find(Player)
	
func GetBoss() -> Boss:
	return Find(Boss)
	
func GetAudioAgent() -> AudioAgent:
	return Find(AudioAgent)

func GetDanceFloor() -> DanceFloor:
	return Find(DanceFloor)
