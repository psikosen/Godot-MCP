@tool
class_name MCPCommandHandlerMinimal
extends Node

func _ready():
	print("Minimal command handler loaded successfully!")
	
func _handle_command(client_id: int, command: Dictionary) -> void:
	print("Received command: ", command)
