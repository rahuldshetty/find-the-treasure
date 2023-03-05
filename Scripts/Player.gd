extends CharacterBody2D

signal died

# State variablesv
var dead: bool = false
var is_digging : bool = false
var dig_time : float = 0.0
var money : float = 0.0
var hp : float = 100

var common_items = [
	[ "Wood", 0 , 17 , { "money": 10, "hp": 0, "speed": 0 , "dig": 0 } ],
	[ "Wooden Shield", 0 , 6, { "money": 40, "hp": 0 ,  "speed": 0 , "dig": 0 }],
	[ "Wooden Sword", 0 , 5, { "money": 25, "hp": 0,  "speed": 0 , "dig": 0 }],
	[ "Armet", 1 , 8, { "money": 0, "hp": 15,  "speed": 0 , "dig": 0.05 }],
	[ "Boots of Travel", 3 , 8, { "money": 0, "hp": 0,  "speed": 0.12 , "dig": 0}],
	[ "Bagpack", 0 , 10, { "money": 50, "hp": 0, "speed": 0 , "dig": 0 } ],
	[ "Axe", 1 , 10, { "money": 100, "hp": 0, "speed": 0 , "dig": 0 } ],
	[ "Pickaxe", 2 , 10, { "money": 80, "hp": 0, "speed": 0 , "dig": 0 } ],
	[ "Shovel", 3 , 10, { "money": 0, "hp": 0, "speed": 0 , "dig": 0.2 }],
	[ "Mushroom", 0 , 12 , { "money": 0, "hp": 40, "speed": 0 , "dig": 0 }],
	[ "Bag of Coins", 6 , 12, { "money": 100, "hp": 0, "speed": 0 , "dig": 0 }],
	[ "Book of Wisdom", 6 , 13, { "money": 50, "hp": 10, "speed": 0.08, "dig": 0 }],
	[ "Apple", 0 , 14, { "money": 0, "hp": 15, "speed": 0, "dig": 0 }],
	[ "Meat", 0 , 15 , { "money": 0, "hp": 30, "speed": 0, "dig": 0 }],
	[ "Banana", 1 , 14 , { "money": 0, "hp": 20, "speed": 0, "dig": 0.05 }],
	[ "Fish Bone", 11 , 16, { "money": 0, "hp": -24, "speed": -0.025, "dig": 0 } ],
	[ "Cheese", 7 , 15 , { "money": 0, "hp": 33, "speed": 0.08, "dig": 0.14 }],
	[ "Honey Pot", 9 , 15, { "money": 0, "hp": 50, "speed": 0.1, "dig": 0.2 } ],
]

var rare_items = [
	[ "Scroll", 10 , 13 , { "money": 0, "hp": 40, "speed": 0.16, "dig": 0.0 }],
	[ "Steel Sword", 1 , 5, { "money": 80, "hp": 0, "speed": 0.0, "dig": 0.0 } ],
	[ "King's Token", 7 , 12 , { "money": 1500, "hp": 0, "speed": 0.0, "dig": 0.0 }],
	[ "Eel", 5 , 16 , { "money": 500, "hp": 0, "speed": 0.0, "dig": 0.0 }],
	[ "Nimo", 7 , 16, { "money": 100, "hp": 0, "speed": 0.08, "dig": 0.0 } ],
	[ "Jelly Fish", 8 , 16 , { "money": 0, "hp": 25, "speed": 0.12, "dig": 0.0 }],
]

var treasure_items = [
	[ "Diamond", 2 , 17, { "money": 2500, "hp": 0, "speed": 0.0, "dig": 0.0 }],
	[ "Soul Mirror", 1 , 11, { "money": 1000, "hp": 0, "speed": 0.0, "dig": 0.0 } ],
	[ "Cursed Bracelet", 7 , 8, { "money": -200, "hp": -20, "speed": -0.15, "dig": 0.0 } ],
	[ "Angel's Harp", 3 , 11, { "money": 500, "hp": 0, "speed": 0.0, "dig": 0.0 } ],
	[ "Treasure Chest", 14 , 16 , { "money": 10000, "hp": 0, "speed": 0.0, "dig": 0.0 }],
]

@export var speed : float = 75
@export var dig_time_base : float = 0.5
@export var max_dig_time : float = 1.8
@export var spend_dig_hp : float = 23

@export var rarity_probability : int = 60
@export var tresure_rarity_probability : int = 95

@onready var animation = $AnimatedSprite2D

# Game Reward/HP 
@onready var money_label = $CanvasLayer/CostLabel
@onready var hp_progress_bar = $CanvasLayer/HP/HP_ProgressBar

# Digging mechanism
@onready var progress_hud = $HUD/DigProgressOut
@onready var progress_bar = $HUD/DigProgressOut/TextureProgressBar
@onready var progress_timer = $HUD/DigProgressOut/ProgressTimer
@onready var dig_result_hud = $HUD/DigResult
@onready var dig_result_label = $HUD/DigResult/Result
@onready var dig_result_icon : Sprite2D = $HUD/DigResult/Icon

func progress_timer_active():
	return progress_timer.time_left != 0
	
func random_progress_time():
	randomize()
	return dig_time_base + randf_range(0.01, max_dig_time)

func _ready():
	dead = false
	is_digging = false
	animation.play("idle")
	progress_hud.visible = false
	dig_result_hud.visible = false
	update_player_hud()

func animate(direction:Vector2):
	if direction.x < 0:
		animation.animation = "walk_left"
		animation.flip_h = false
	elif direction.x > 0:
		animation.animation = "walk_left"
		animation.flip_h = true
	elif direction.y > 0:
		animation.animation = "walk_down"
	elif direction.y < 0:
		animation.animation = "walk_up"
	else:
		animation.animation = "idle"
		animation.flip_h = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	animate(input_direction)
	if input_direction != Vector2.ZERO:
		hide_dig_result()
	velocity = input_direction * speed

func get_random_item():
	randomize()
	var rarity = randi_range(0, 100)
	var rarity_key = common_items
	if rarity >= rarity_probability:
		rarity_key = rare_items
	
	if rarity >= tresure_rarity_probability:
		rarity_key = treasure_items
		
	var sub_items = rarity_key
	
	randomize()
	var idx = randi_range(0, len(sub_items) - 1)
	
	return sub_items[idx]

func show_dig_result():
	var item = get_random_item()
	
	dig_result_label.text = "Found " + item[0]
	dig_result_hud.visible = true
	
	var newRegion = Rect2(32 * item[1], 32 * item[2], 32, 32)
	dig_result_icon.region_rect = newRegion
	
	var rewards = item[3]
	
	money += rewards['money']
	hp = min(100, hp + rewards['hp'])
	update_player_hud()
	
	if hp <= 0:
		dead = true
		died.emit()
	
	speed += speed * rewards['speed']
	max_dig_time -= max_dig_time * rewards['dig']

func hide_dig_result():
	dig_result_hud.visible = false

func start_digging():
	is_digging = true
	progress_hud.visible = true
	animation.animation = "dig"
	dig_time = random_progress_time()
	progress_timer.start(dig_time)
	
	hp -= spend_dig_hp
	update_player_hud()
	
func stop_digging():
	is_digging = false
	progress_hud.visible = false
	animation.animation = "idle"
	
func update_progress_bar():
	progress_bar.value = int( 100 - 100 * progress_timer.time_left/dig_time )

func _input(_event):
	if not is_digging and not dead and Input.is_key_pressed(KEY_E):
		start_digging()
	
func _physics_process(_delta):
	if not is_digging and not dead:
		get_input()
		move_and_slide()

func _process(_delta):
	if is_digging:
		hide_dig_result()
		update_progress_bar()

func _on_progress_timer_timeout():
	stop_digging()
	show_dig_result()


func update_player_hud():
	hp_progress_bar.value = hp
	money_label.text = "$ " + str(int(money))
