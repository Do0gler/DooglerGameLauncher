extends Resource

class_name Game_Data

@export var file_size_mb : float
@export var download_path : String
@export var game_name : String
@export var file_name : String
@export var game_file_name : String
@export var api_icon_name := "logo"
@export var version_number := "1.0"
@export var has_discord_rpc := false
var is_outdated := false
@export_multiline var description : String
@export_enum("Scratch", "Unity", "Godot") var engine: String = "Scratch"
@export var creation_date: String = "Unknown" #MM/DD/YYYY
@export var icon : Texture2D
@export var background : Texture2D
@export var screenshots : Array[Texture2D]
@export var tags : Array[String]
