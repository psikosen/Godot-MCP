@tool
class_name ResourceUtils
extends RefCounted

# Returns the simplified res:// path, or "" when the path resolves outside the project folder.
# Every MCP-driven write goes through this: a client must never write outside res://
# (e.g. "res://../x", absolute paths, user://).
static func contained_res_path(path: String) -> String:
	if path.is_empty():
		return ""
	if "://" in path and not path.begins_with("res://"):
		return ""
	if not path.begins_with("res://") and path.is_absolute_path():
		# OS path (/Users/..., C:/...): allowed only when it points inside the project folder.
		path = ProjectSettings.localize_path(path)
		if not path.begins_with("res://"):
			return ""
	if not path.begins_with("res://"):
		path = "res://" + path
	var simplified := path.simplify_path()
	if not simplified.begins_with("res://"):
		return ""
	if ".." in simplified.trim_prefix("res://").split("/"):
		return ""
	# Final word: where Godot would really put the file.
	var root := ProjectSettings.globalize_path("res://")
	if not root.ends_with("/"):
		root += "/"
	if not ProjectSettings.globalize_path(simplified).begins_with(root):
		return ""
	return simplified

# Load a resource safely, returning null if it fails
static func safe_load(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		push_error("Resource does not exist: " + path)
		return null
	
	var res = ResourceLoader.load(path)
	if not res:
		push_error("Failed to load resource: " + path)
		return null
	
	return res

# Save a resource safely, returning true if successful
static func safe_save(resource: Resource, path: String) -> bool:
	if not resource:
		push_error("Cannot save null resource")
		return false
	var contained := contained_res_path(path)
	if contained.is_empty():
		push_error("Refusing to save outside the project (res://): " + path)
		return false
	path = contained
	
	# Make sure directory exists
	var dir_path = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		var err = DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			push_error("Failed to create directory: " + dir_path)
			return false
	
	var result = ResourceSaver.save(resource, path)
	if result != OK:
		push_error("Failed to save resource: " + path)
		return false
	# The in-memory resource now lives at `path`, so nodes using it reference the file (ext_resource)
	# instead of embedding a copy that later edits to the file never reach. (FLAG_CHANGE_PATH does
	# not set the path in Godot 4.7; take_over_path does.)
	resource.take_over_path(path)
	
	return true

# Create a new resource instance by type name
static func create_resource(type_name: String) -> Resource:
	if not ClassDB.class_exists(type_name):
		push_error("Class does not exist: " + type_name)
		return null
	
	if not ClassDB.is_parent_class(type_name, "Resource"):
		push_error("Class is not a Resource: " + type_name)
		return null
	
	if not ClassDB.can_instantiate(type_name):
		push_error("Cannot instantiate Resource class: " + type_name)
		return null
	
	return ClassDB.instantiate(type_name)

# Get a list of all resource types that inherit from a base class
static func get_resource_types(base_class: String = "Resource") -> Array[String]:
	var result: Array[String] = []
	
	for class_type in ClassDB.get_class_list():
		if ClassDB.is_parent_class(class_type, base_class) and ClassDB.can_instantiate(class_type):
			result.append(class_type)
	
	return result

# Convert a resource to a JSON-compatible dictionary
static func resource_to_dict(resource: Resource) -> Dictionary:
	var result = {
		"resource_path": resource.resource_path,
		"resource_name": resource.resource_name,
		"type": resource.get_class(),
		"properties": {}
	}
	
	# Get properties
	var property_list = resource.get_property_list()
	for prop in property_list:
		var prop_name = prop["name"]
		if not prop_name.begins_with("_") and prop_name != "resource_path" and prop_name != "resource_name":
			result["properties"][prop_name] = resource.get(prop_name)
	
	return result
