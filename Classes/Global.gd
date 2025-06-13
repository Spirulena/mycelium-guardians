extends Node

var main: Main
var settings: Dictionary

# instead of learning how to use custom resource and pass that we will use Global
# for base gene

var gene_base_decay_time: float = 12
var gene_base_smog_change:float = 1.0/30.0
var gene_base_growth_factor: float = 1.0
var gene_base_color: Color = Color.WHITE
var gene_base_generation: int = 1
var gene_base_mutation_id_origin: String
var gene_base_generation_origin: int

# NOTE: store starting point or history of generations ?

# move settings to resource so we can change it at run time
func _init() -> void:
	settings = {}
	settings['mycelium'] = {
		'process_water': true,
		'process_resource_extraction': true,
	}
