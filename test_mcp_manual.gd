extends Node

# Manual test script to start the MCP WebSocket server
# Attach this to a Node in your scene and run it

var tcp_server := TCPServer.new()
var port := 9080
var clients := {}
var next_client_id := 1

class WebSocketClient:
	var tcp: StreamPeerTCP
	var id: int
	var ws: WebSocketPeer
	var state: int = -1 # -1: handshaking, 0: connected
	
	func _init(p_tcp: StreamPeerTCP, p_id: int):
		tcp = p_tcp
		id = p_id

func _ready():
	print("=== MANUAL MCP SERVER TEST ===")
	var err = tcp_server.listen(port)
	if err == OK:
		print("✓ TCP Server listening on port ", port)
	else:
		print("✗ Failed to start TCP server on port ", port, " - Error: ", err)
		return
	
	set_process(true)
	print("=== Server running. Waiting for connections... ===")

func _process(_delta):
	# Accept new connections
	if tcp_server.is_connection_available():
		var tcp = tcp_server.take_connection()
		var id = next_client_id
		next_client_id += 1
		
		var client = WebSocketClient.new(tcp, id)
		clients[id] = client
		
		print("[Client ", id, "] New TCP connection from ", tcp.get_connected_host())
		
		# Upgrade to WebSocket
		client.ws = WebSocketPeer.new()
		var upgrade_err = client.ws.accept_stream(tcp)
		if upgrade_err == OK:
			print("[Client ", id, "] WebSocket upgrade initiated")
		else:
			print("[Client ", id, "] Failed to upgrade to WebSocket: ", upgrade_err)
			clients.erase(id)
	
	# Process existing clients
	var ids_to_remove := []
	for id in clients:
		var client = clients[id]
		
		if client.state == -1: # Handshaking
			client.ws.poll()
			var ws_state = client.ws.get_ready_state()
			
			print("[Client ", id, "] WebSocket state: ", ws_state)
			
			if ws_state == WebSocketPeer.STATE_OPEN:
				print("[Client ", id, "] ✓ WebSocket connection established!")
				client.state = 0
				
				# Send welcome message
				var welcome = JSON.stringify({
					"type": "welcome",
					"message": "Connected to Godot MCP test server"
				})
				client.ws.send_text(welcome)
				
			elif ws_state != WebSocketPeer.STATE_CONNECTING:
				print("[Client ", id, "] ✗ WebSocket handshake failed, state: ", ws_state)
				ids_to_remove.append(id)
		
		elif client.state == 0: # Connected
			client.ws.poll()
			var ws_state = client.ws.get_ready_state()
			
			if ws_state != WebSocketPeer.STATE_OPEN:
				print("[Client ", id, "] Disconnected")
				ids_to_remove.append(id)
				continue
			
			# Handle messages
			while client.ws.get_available_packet_count() > 0:
				var packet = client.ws.get_packet()
				var text = packet.get_string_from_utf8()
				print("[Client ", id, "] Received: ", text)
				
				# Echo back
				var response = JSON.stringify({
					"status": "success",
					"message": "Echo: " + text
				})
				client.ws.send_text(response)
	
	# Clean up disconnected clients
	for id in ids_to_remove:
		clients.erase(id)

func _exit_tree():
	tcp_server.stop()
	print("=== Server stopped ===")
