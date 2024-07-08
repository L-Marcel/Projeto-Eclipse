@icon("res://assets/icons/Popup.svg")
class_name Interaction
extends Node

var enabled = true;
var focused = false;

signal action(by : Node);
signal focus;
signal unfocus;

func _ready():
	focus.connect(_on_focus);
	unfocus.connect(_on_unfocus);
func _on_focus():
	focused = true;
func _on_unfocus():
	focused = false;
func is_possible():
	return action.get_connections().size() == 1 && enabled;
func registry(callable : Callable):
	for connection in action.get_connections():
		action.disconnect(connection);
	action.connect(callable);
func unregistry():
	for connection in action.get_connections():
		unfocus.emit();
		action.disconnect(connection["callable"]);
