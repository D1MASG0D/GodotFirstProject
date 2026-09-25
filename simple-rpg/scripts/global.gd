extends Node

var playerCurrentAttack = false
var currentScene= "world" #world cliffSide
var transitionScene=false

var playerExitCliffSide_posX=280.0
var playerExitCliffSide_posY=38.0
var playerStart_posX=0
var playerStart_posY=0

var gameFirstLoading = true

func finishChangingScenes():
	transitionScene=false
	if currentScene == "world":
		currentScene= "cliff_side"
	else:
		currentScene= "world"

func resetGame():
	transitionScene=false
	currentScene= "world"
	gameFirstLoading= true
