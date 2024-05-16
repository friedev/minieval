extends Node

## Config file path.
const CONFIG_PATH := "user://options.cfg"
## Section of the config file under which all options are saved.
const OPTIONS_SECTION := "options"
## Node group containing all Option-derived nodes.
const OPTIONS_GROUP := &"options"

## Currently loaded options.
var options := {}


## Set each option to its value read from the config file.
func load_config() -> bool:
	var config := ConfigFile.new()
	var err := config.load(self.CONFIG_PATH)
	if err != OK:
		return false
	for option_node in self.get_tree().get_nodes_in_group(self.OPTIONS_GROUP):
		var option := option_node as Option
		if config.has_section_key(self.OPTIONS_SECTION, option.key):
			option.set_option(
				config.get_value(self.OPTIONS_SECTION, option.key), false
			)
	return true


## Save the currently loaded options to the config file.
func save_config() -> bool:
	var config := ConfigFile.new()
	for option_node in self.get_tree().get_nodes_in_group(self.OPTIONS_GROUP):
		var option := option_node as Option
		config.set_value(self.OPTIONS_SECTION, option.key, option.get_option())
	return config.save(self.CONFIG_PATH) == OK


## Set each option to its default value.
func apply_defaults() -> void:
	for option_node in self.get_tree().get_nodes_in_group(self.OPTIONS_GROUP):
		var option := option_node as Option
		option.set_option(option.default, false)


## Set the options to their currently loaded values.
func apply_options() -> void:
	for option_node in self.get_tree().get_nodes_in_group(self.OPTIONS_GROUP):
		var option := option_node as Option
		if option.key in self.options:
			option.set_option(self.options[option.key], false)


## Perform initial options setup on game start. To be called by the root node of
## the startup scene to ensure that all Option nodes have entered the tree.
# (The Option nodes should be present in the startup scene.)
func setup() -> void:
	if options.is_empty():
		# Apply defaults to ensure every option is set
		Options.apply_defaults()
		# Load from config file, overwriting default options
		Options.load_config()
		# Re-save the config, including the default values for any unset options
		Options.save_config()
