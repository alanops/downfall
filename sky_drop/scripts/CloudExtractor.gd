@tool
extends Node

# Tool script to help extract individual clouds from sprite sheets
# This creates placeholder data for cloud positions that can be used
# to manually extract clouds in an image editor

# Cloud region data for each texture
var cloud_regions = {
	"clouds_sparse_middle_layer": [
		{"name": "wispy_small_1", "pos": Vector2(50, 100), "size": Vector2(150, 80)},
		{"name": "wispy_small_2", "pos": Vector2(300, 200), "size": Vector2(180, 90)},
		{"name": "wispy_medium_1", "pos": Vector2(600, 150), "size": Vector2(200, 100)},
		{"name": "wispy_thin_1", "pos": Vector2(100, 400), "size": Vector2(250, 60)},
	],
	"clouds_dramatic_foreground": [
		{"name": "fluffy_large_1", "pos": Vector2(0, 50), "size": Vector2(400, 250)},
		{"name": "fluffy_large_2", "pos": Vector2(500, 100), "size": Vector2(350, 200)},
		{"name": "fluffy_medium_1", "pos": Vector2(200, 350), "size": Vector2(300, 180)},
		{"name": "fluffy_medium_2", "pos": Vector2(600, 400), "size": Vector2(280, 160)},
		{"name": "fluffy_small_1", "pos": Vector2(50, 600), "size": Vector2(200, 120)},
	],
	"clouds_mixed_original": [
		{"name": "mixed_large_1", "pos": Vector2(100, 100), "size": Vector2(350, 200)},
		{"name": "mixed_medium_1", "pos": Vector2(500, 50), "size": Vector2(250, 150)},
		{"name": "mixed_medium_2", "pos": Vector2(150, 350), "size": Vector2(280, 170)},
		{"name": "mixed_small_1", "pos": Vector2(600, 300), "size": Vector2(180, 100)},
	]
}

func extract_cloud_data():
	print("=== Cloud Extraction Guide ===")
	print("Use these regions to manually extract clouds in your image editor:")
	print("")
	
	for texture_name in cloud_regions:
		print("\nTexture: " + texture_name + ".webp")
		print("-" * 40)
		
		for cloud in cloud_regions[texture_name]:
			print("Cloud: " + cloud.name)
			print("  Position: x=" + str(cloud.pos.x) + ", y=" + str(cloud.pos.y))
			print("  Size: " + str(cloud.size.x) + "x" + str(cloud.size.y))
			print("")

# For now, we'll create a system that uses existing cloud scenes
# but spawns them dynamically instead of as static parallax layers