extends Node
# ///////////////////////////////////////////////////////////////
# script created to help with the information that bosses will need
# ///////////////////////////////////////////////////////////////

var boss
# //////////////////////////////////////////////////////////
# ////////////////////// SIGNALS ///////////////////////////
# //////////////////////////////////////////////////////////

func bosses_detection_entered(body: Node3D) -> void:
	if body.is_in_group("Boss"):
		boss = body
func bosses_detection_exited(body: Node3D) -> void:
	if body.is_in_group("Boss"):
		boss = null
