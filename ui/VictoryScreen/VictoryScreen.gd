extends Control


func _ready() -> void:
	var boss := GlobalContext.GetBoss()
	var isBossDead := boss.damageTaken >= boss.maximumHealth
	var isHitless := Stats.totalDamageTaken == 0.0
	var isHighAccuracy := boss.damageTaken >= Stats.CalculateOptimalDamage() * 0.95
	
	var isBossDeadBefore: bool = Achievements.LoadValue("boss_killed", false)
	var isHitlessBefore: bool = Achievements.LoadValue("hitless", false)
	var isHighAccuracyBefore: bool = Achievements.LoadValue("high_accuracy", false)
	Achievements.SaveValue("boss_killed", isBossDead || isBossDeadBefore)	
	Achievements.SaveValue("hitless", isHitless || isHitlessBefore)
	Achievements.SaveValue("high_accuracy", isHighAccuracy || isHighAccuracyBefore)
	
	var totalStarCount := 1
	if isBossDead or isBossDeadBefore:
		totalStarCount += 1
	if isHitless or isHitlessBefore:
		totalStarCount += 1
	if isHighAccuracy or isHighAccuracyBefore:
		totalStarCount += 1
		
	var stars := ""
	for i in range(totalStarCount):
		stars += "★"
	for i in range(4 - totalStarCount):
		stars += "☆"
	$Panel/Control/VBoxContainer/StarCountLabel.text = stars
	
	var killedBossStar := $Panel/Control/VBoxContainer/VBoxContainer/HBoxContainer2/KilledBossStar
	var hitlessStar := $Panel/Control/VBoxContainer/VBoxContainer/HBoxContainer3/HitlessStar
	var highUptimeStar := $Panel/Control/VBoxContainer/VBoxContainer/HBoxContainer4/HighUptimeStar
	
	$Panel/Control/VBoxContainer/StarCountLabel.add_theme_color_override("font_color", Color.GOLD)
	$Panel/Control/VBoxContainer/VBoxContainer/HBoxContainer/SurvivedStar.add_theme_color_override("font_color", Color.GOLD)
	
	if isBossDead:
		killedBossStar.add_theme_color_override("font_color", Color.GOLD)
		killedBossStar.text = "★"
	elif isBossDeadBefore:
		killedBossStar.add_theme_color_override("font_color", Color.PALE_GOLDENROD)
		killedBossStar.text = "★"
	else:
		killedBossStar.text = "☆"
		
	if isHitless:
		hitlessStar.add_theme_color_override("font_color", Color.GOLD)
		hitlessStar.text = "★"
	elif isHitlessBefore:
		hitlessStar.add_theme_color_override("font_color", Color.DARK_GOLDENROD)
		hitlessStar.text = "★"
	else:
		hitlessStar.text = "☆"
		
	if isHighAccuracy:
		highUptimeStar.add_theme_color_override("font_color", Color.GOLD)
		highUptimeStar.text = "★"
	elif isHighAccuracyBefore:
		highUptimeStar.add_theme_color_override("font_color", Color.PALE_GOLDENROD)
		highUptimeStar.text = "★"
	else:
		highUptimeStar.text = "☆"
		
