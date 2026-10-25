extends Control

@onready var label: Label = $Panel/Panel/Label
@onready var score: Label = $Panel/Panel/Score
@onready var customers_served: Label = $Panel/Panel/customers_served

func setup_for_scene_():
	$Panel/Panel/Label4.hide()
	$Panel/Panel/Label5.hide()
	$Panel/Panel/Label6.hide()
	$Panel/Panel/BacktoMenu.hide()
	$Panel/Panel/BacktoMenu.disabled = true
	$Panel/Panel/Label.show()
	$Panel/Panel/Score.show()
	$Panel/Panel/customers_served.show()
	$Panel/Panel/continue.disabled = false
	$Panel/Panel/continue.show()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_for_scene_()
	#label.text = "There are no more customers for today!!"
	#score.text = "Score: \n" + str(PlayerStatus.score)
	#customers_served.text = "Happy Customers: \n" + str(PlayerStatus.happy_customers_today) + " / " + str(PlayerStatus.max_customers_in_day)


func _on_continue_pressed() -> void:
	$Panel/Panel/Label.hide()
	$Panel/Panel/Score.hide()
	$Panel/Panel/customers_served.hide()
	$Panel/Panel/continue.disabled = true
	$Panel/Panel/continue.hide()
	$Panel/Panel/Label4.show()
	$Panel/Panel/Label5.show()
	$Panel/Panel/Label6.show()
	$Panel/Panel/BacktoMenu.show()
	$Panel/Panel/BacktoMenu.disabled = false

func _on_backto_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn") 
