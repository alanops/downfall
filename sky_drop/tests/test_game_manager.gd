extends GutTest

var GameManager = preload("res://scripts/GameManager.gd")
var game_manager

func before_each():
	game_manager = GameManager.new()

func after_each():
	if game_manager:
		game_manager.queue_free()

func test_initial_game_state():
	assert_eq(game_manager.score, 0, "Score should start at 0")
	assert_eq(game_manager.game_time, 0.0, "Game time should start at 0")
	assert_eq(game_manager.game_state, "menu", "Game should start in menu state")
	assert_eq(game_manager.fall_speed_multiplier, 1.0, "Speed multiplier should start at 1.0")

func test_score_increment():
	var initial_score = game_manager.score
	game_manager._add_score(10)
	assert_eq(game_manager.score, initial_score + 10, "Score should increase by 10")

func test_game_state_transitions():
	# Start game
	game_manager.start_game()
	assert_eq(game_manager.game_state, "playing", "Game state should be playing")
	assert_eq(game_manager.score, 0, "Score should reset on start")
	
	# Game over
	game_manager.game_over()
	assert_eq(game_manager.game_state, "game_over", "Game state should be game_over")

func test_fall_speed_progression():
	game_manager.game_time = 10.0
	var speed = game_manager._calculate_fall_speed_multiplier()
	assert_gt(speed, 1.0, "Fall speed should increase over time")
	
	game_manager.game_time = 30.0
	var speed2 = game_manager._calculate_fall_speed_multiplier()
	assert_gt(speed2, speed, "Fall speed should continue increasing")

func test_game_duration():
	game_manager.start_game()
	game_manager.game_time = 44.0
	assert_false(game_manager._is_game_complete(), "Game should not be complete before 45 seconds")
	
	game_manager.game_time = 45.0
	assert_true(game_manager._is_game_complete(), "Game should be complete at 45 seconds")

func test_hazard_spawn_rate():
	# Early game
	game_manager.game_time = 5.0
	var rate1 = game_manager._get_hazard_spawn_rate()
	
	# Late game
	game_manager.game_time = 30.0
	var rate2 = game_manager._get_hazard_spawn_rate()
	
	assert_lt(rate2, rate1, "Spawn interval should decrease (more frequent) over time")

func test_powerup_spawn_probability():
	# Test that powerup spawn probability is reasonable
	var spawn_count = 0
	for i in range(100):
		if game_manager._should_spawn_powerup():
			spawn_count += 1
	
	# Should spawn roughly 20% of the time
	assert_between(spawn_count, 10, 30, "Powerup spawn rate should be around 20%")