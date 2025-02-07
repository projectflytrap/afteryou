class_name Serializable


# Convert instance to a dictionary.
func to_dict() -> Dictionary:
	var result = {
		"_type": get_script().get_path()  # This is a reference to the class/script type.
	}
	
	for property in self.get_property_list():
		#print("Property name: ", property.name, " Usage: ", property.usage)
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			result[property.name] = get(property.name)
	
	return result


# Populate the instance from a dictionary.
static func from_dict(data: Dictionary) -> Serializable:
	var instance = load(data["_type"]).new()
	
	for key in data.keys():
		if key != "_type":
			instance.set(key, data[key])
	
	return instance
