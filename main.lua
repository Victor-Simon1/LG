io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end
-------AFFICHAGE--------------
affichage = "menu"
------LISTE--------------
players = {}
roles = {}
bouttons = {}
panels = {}
objects = {}
objetRecupExte = {}
objetRecupMine = {}
messages = {}
competence = {"name","pvp","guessrole","pve","contreArguments","minages","maskedRole"}
competenceRole = {"name","camp"}
competenceObject = {"name","drop","endroit"}
------VARIABLE----------
cd = 1
fullscreen = false
Loup ,Village ,Neutre =0,0,0
bo = love.graphics.newImage("Images/boutonBasique.png"):getWidth()
------IMAGES/FONT---------------
fontBase = love.graphics.newFont("Images/blocked.ttf", 20)
imgBouttonHover = love.graphics.newImage("Images/boutonBasiqueHover.png")
imgBoutton =  love.graphics.newImage("Images/boutonBasique.png")
font = love.graphics.newFont("Images/blocked.ttf", 12)
imgFond = love.graphics.newImage("Images/imgFond.jpg")
love.graphics.setFont(fontBase)
-------------REQUIRE--------------------
Menu = require("menu")
Game = require("game")
PreGame = require("pregame")
Gameover = require("gameover")
Parametre = require("parametre")

function MyButton(pImg,pImgHover,pX,pY,pWidth,pHeight,types,pFonc,pPara,isSelect)
	local boutton = {}
	boutton.img = love.graphics.newImage("Images/"..pImg..".png")
	boutton.imgHover = love.graphics.newImage("Images/"..pImgHover..".png")
	boutton.w = pWidth
	boutton.h =  pHeight
	boutton.x = pX - boutton.w / 2
	boutton.y = pY 
	boutton.initY = pY
	boutton.isSelect = isSelect
	boutton.fonction = pFonc
	boutton.parametre = pPara
	boutton.type = types

	table.insert(bouttons,boutton)
	return boutton
end

function createPanel(pX,pY,pWidth,pHeight,pIsVisible)
	local panel = {}
	panel.x = pX
	panel.y = pY
	panel.w = pWidth
	panel.h = pHeight
	panel.element = {}
	panel.isVisible = pIsVisible
	function panel:setImage(pImage)
   		self.Image = pImage
    	self.w = pImage:getWidth()
    	self.h = pImage:getHeight()
  	end
  	function panel:add(pElement )
  		self.element[#panel.element + 1] = pElement
  	end
	table.insert(panels,panel)
end


function createPlayer()
	local player = {}
	local file = io.open("players.txt",r)
	for lines in io.lines("players.txt") do
		if lines == "----------------------" then
			player["imgHead"] = love.graphics.newImage("Images/"..player["name"].."Head.png")
			player.w = 20
			player.h = 20
			player["connaissance"] = {}
			player["messageAffiche"] = {}
			player["inventaire"] = {}
			player["minage"] = false
			player["tableEnchant"] = false
			player["ptsProtection"] = 0
			player["epee"] = 0
			player["affichage"] = false
			player["select"] = false
			player["mort"] = false
			player["role"] = {name = "Non Attribue"}
			player["versCentre"] = false
			player["couple"] = false
			player["kills"] = 0
			player["vie"] = 20
			player["border"] = {}
			player["armure"] = {}
			player["target"] = {}
			player["ennemie"] = 0
			player["allie"] = 0
			player["minageExte"] = false
			player["minageCave"] = false
			player["estAttaque"] = nil
			cd = 1
			table.insert(players,player)
			player = {}
		else 
			player[competence[cd]] = lines
			cd = cd +1
		end
	end
	io.close(file)
end
function createRoles( )
	local role = {}
	local file1 = io.open("roles.txt",r)
	for lines in io.lines("roles.txt") do
		if lines == "----------------------" then
			role["select"] = false
			cd = 1
			table.insert(roles,role)
			role = {}
		else
			role[competenceRole[cd]] = lines
			cd = cd +1
		end
	end
	io.close(file1)
end

function createObject(nomObj,player,tab)
	local object = {}
	if nomObj ~= nil then
		object["name"] = nomObj
		object["img"] =  love.graphics.newImage("Images/"..nomObj..".png")
		object["nombre"] = 1
	
		table.insert(player[tab],object)
		object = {}
	else
		local file1 = io.open("object.txt",r)
		for lines in io.lines("object.txt") do
			if lines == "----------------------" then
				object["select"] = false
				object["img"] = love.graphics.newImage("Images/"..object["name"]..".png")
				object["nombre"] = 1
				object["drop"] = tonumber(object["drop"] )
				cd = 1
				
				if object["endroit"] == "surface" then
					table.insert(objetRecupExte,object)
				else
					table.insert(objetRecupMine,object)
				end
				table.insert(objects,object)
				object = {}
			else
				object[competenceObject[cd]] = lines
				cd = cd +1
			end
		end
		io.close(file1)
	end
end

function createMessage(contenu,types)
	local message = {}
	message["contenu"] = contenu
	message["type"] = types
	table.insert(messages,message)
	return message
end
function objectInCollide(o1,o2)
  if o1.x <= o2.x + o2.w and o2.x <= o1.x + o1.w and o1.y <= o2.y + o2.h and o2.y <= o1.y+o1.h then
    return true
  end
  return false
end

function objectInCercle(object,circle)
	local phg = math.pow(object.x - circle.x,2) +  math.pow(object.y - circle.y,2) < math.pow(circle.r,2)
	local phd = math.pow(object.x + object.w - circle.x,2) +  math.pow(object.y - circle.y,2) < math.pow(circle.r,2)
	local pbg = math.pow(object.x - circle.x,2) +  math.pow(object.y + object.h - circle.y,2) < math.pow(circle.r,2)
	local pbd = math.pow(object.x + object.w - circle.x,2) +  math.pow(object.y + object.h - circle.y,2) < math.pow(circle.r,2)
	if phg or phd or pbg or pbd then
		return true
	end
	return false
end
function aff(paff)
  	local  y = 100
  	if paff == "menu" then
  		Menu.load()
  	end
  	if paff == "pregame" then
    	PreGame.load()
  	end
  	if paff == "game" then
  		Game.load()
  	end
  	if paff == "gameover" then
  		Gameover.load()
  	end
  	if paff == "statistique" then
 		Statistique.load()
  	end
  	if paff == "parametre" then
  		Parametre.load()
  	end 
end

function selectButton(i)
	if bouttons[i].type["select"] == false then
		bouttons[i].img = imgBouttonHover
	else
		bouttons[i].img = imgBoutton
	end
	bouttons[i].type["select"] = not bouttons[i].type["select"]
end

function quitter()
	love.event.quit()
end
function love.load()
	aff("menu")
	vainqueur = ""
 	love.window.setMode(1024,768)
end
function love.update(dt)
	mouse = {}
	mouse.x,mouse.y,mouse.w,mouse.h =love.mouse.getX(),love.mouse.getY(),1,1 
	if affichage =="menu" then
 		Menu.update(dt)
 	elseif affichage == "game" then
 		Game.update(dt)
 	elseif affichage == "pregame" then
 		PreGame.update(dt)
 	end
end

function love.draw()
	if affichage =="menu" then
		love.graphics.draw(imgFond,0,0,0,1024 / imgFond:getWidth() , 768  / imgFond:getHeight())
 		Menu.draw()
 	elseif affichage =="game" then
 		Game.draw()
 	elseif affichage == "gameover" then
 		Gameover.draw()
 	elseif affichage == "pregame" then
 		love.graphics.draw(imgFond,0,0,0,1024 / imgFond:getWidth() , 768  / imgFond:getHeight())
 		PreGame.draw()
 	elseif affichage == "parametre" then
 		Parametre.draw()
 	end
end
function love.keypressed(key)
	if key =="p" and fullscreen == false then
		local w,h = love.graphics.getWidth() ,love.graphics.getHeight()
		love.window.setFullscreen(true, "desktop")
		fullscreen = true
	elseif key == "p" and fullscreen == true then
		local w,h = love.graphics.getWidth() ,love.graphics.getHeight()
		love.window.setMode(1024,768)
		fullscreen = false
	end
	Menu.keypressed(key)
	if affichage == "game" then
		Game.keypressed(key)
	end
end
function love.mousepressed()
	if affichage == "menu" then
  		Menu.mousepressed()
  	end
  	if affichage == "pregame" then
    	PreGame.mousepressed()
  	end
  	if affichage == "game" then
  		Game.mousepressed()
  	end
  	if affichage == "gameover" then
  		Gameover.mousepressed()
  	end
  	if affichage == "statistique" then
 		Statistique.mousepressed()
  	end
  	if affichage == "parametre" then
  		Parametre.mousepressed()
  	end 
end
function love.mousereleased()
	if affichage == "pregame" then
		PreGame.mousereleased()
	end
end