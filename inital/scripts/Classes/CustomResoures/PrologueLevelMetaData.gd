class_name PrologueLevelMetaData extends Resource
## Prologue Selection
## 		1: {
## 			'index': 1,
## 			'name': 'mycelium',
## 			'scene_key': 'tutorial_01_mycelium',
## 			'icon': 'TODO: add mycelium icon path',
## 			'enable': true,
## 			'button': null,
## 		},

@export_category("Test")
@export var name: String
@export var scene_key: String
@export var icon: Texture2D
@export var enable: bool = false
@export var button: NodePath
