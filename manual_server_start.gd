extends Node

# Manual server starter for debugging
var tcp_server := TCPServer.new()
var port := 9080

func _ready():
	print("\n=== MANUAL SERVER START ===")
	var err = tcp_server.listen(port)
	if err == OK:
		print("✓ Successfully listening on port ", port)
		set_process(true)
	else:
		print("✗ Failed to listen on port ", port, " - Error: ", err)
		print("Error codes: OK=0, ERR_ALREADY_IN_USE=46, ERR_CANT_CREATE=31, ERR_UNAVAILABLE=43")
	print("=== END MANUAL START ===\n")

func _process(_delta):
	if tcp_server.is_listening() and tcp_server.is_connection_available():
		var conn = tcp_server.take_connection()
		print("Got connection from: ", conn.get_connected_host(), ":", conn.get_connected_port())
