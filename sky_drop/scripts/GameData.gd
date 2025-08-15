extends Node

# Global game data that persists between scenes
var final_score = 0
var final_time = 0.0
var final_lives = 0

func set_game_results(score: int, time: float, lives: int):
	final_score = score
	final_time = time
	final_lives = lives
	print("GameData: Stored results - Score: ", score, " Time: ", time, " Lives: ", lives)