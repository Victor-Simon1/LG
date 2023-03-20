local Pregame = {}

getW = love.graphics.newImage("Images/boutonBasique.png"):getWidth()
getH = love.graphics.newImage("Images/boutonBasique.png"):getHeight()
function  choosePlayer()
	playersSelect = {}
	for i=1,#players do
		if players[i]["select"] == true then
			table.insert(playersSelect,players[i])
		end
	end
	return #playersSelect
end
function chooseRoles()
	rolesSelect = {}
	for i=1,#roles do
		if roles[i]["select"] == true then
			if roles[i]["name"] == "Soeur"then
				table.insert(rolesSelect,roles[i])
			end
			table.insert(rolesSelect,roles[i])
		end
	end
	return #rolesSelect +a
end

function Pregame.load( )
	affichage = "pregame"
	createPlayer()
 	createRoles()
 	createObject()
	playersSelect = {}
	rolesSelect = {}
	bouttons = {}
	y = 100
	a = 0
	ancien = 0 
	bouttonMaintenu = false
	windows = {x =0 , y = 0,width = 1024,height = 768}
	camera = {x =0 , y = 0}
	s ={x = 0,y = 0 ,w= 20,h = 768 }
	local width = 250
	local height = 50
    	for i=1,#players do
			MyButton("boutonBasique","boutonBasiqueHover",bo / 2 + s.w + 10,0+ y *i ,width,height,players[i],selectButton,i,false)	
			players[i]["select"] = false
		end
		nbBut1 = #bouttons
		--s.h = 768 /(bouttons[#bouttons].y /768 )
		for z=1,#roles do
			MyButton("boutonBasique","boutonBasiqueHover",1024 - bo / 2 - 50,0+ y *z,width,height,roles[z],selectButton,z + #players,false)
			roles[z]["select"] = false
		end
		nbBut2 = #bouttons - nbBut1
		if nbBut1 > nbBut2 then
			s.h = 768 /(bouttons[nbBut1].y /768 )
			proportion = (bouttons[nbBut1].y - bouttons[1].y  -(768 - y- bouttons[nbBut1].h) )  / ((windows.height - s.h) - 0 )
		else
			s.h = 768 /(bouttons[#bouttons].y /768 )
			proportion = (bouttons[#bouttons].y - bouttons[1].y -(768 -y - bouttons[#bouttons].h) )  / ((windows.height - s.h) - 0 )
		end
		MyButton("boutonJouer","boutonJouer",512,200,width,height,"nil",aff,"game",false)
		MyButton("boutonRetour","boutonRetour",512,300,width,height,"nil",aff,"menu",false)
	--proportion = (bouttons[#bouttons].y - bouttons[1].y )  / ((windows.height - s.h) - 0 )
end
function Pregame.update( dt )
	if objectInCollide(s,mouse) then
		if love.mouse.isDown(1) then
			if bouttonMaintenu == false then
				bouttonMaintenu = true
				ecartY = love.mouse.getY() - s.y
			end
			s.y = love.mouse.getY() - ecartY
			if s.y < 0 then
				s.y = 0
			elseif s.y + s.h > windows.height then
				s.y = windows.height - s.h
			end
			--camera.y = camera.y + (s.y - ancien ) * proportion
			for i=1,#bouttons do
				bouttons[i].y = bouttons[i].y -  (s.y - ancien ) * proportion
			end
			ancien = s.y
	
		else 
			bouttonMaintenu = false
		end
	end
end
function Pregame.draw()
	love.graphics.rectangle("fill",s.x,s.y,s.w,s.h)
	love.graphics.print({{255,255,255}, ""..choosePlayer().." joueur(s) choisis"},512-100,400 , 0)
	love.graphics.print({{255,255,255}, ""..chooseRoles().."role(s) choisis"},512-100,500 , 0)
	love.graphics.print({{255,255,255}, "Choissisez 10 joueurs au moins"}, 320,600, 0)
	for i=1,#bouttons do
		b = bouttons[i]
		love.graphics.draw(b.img,b.x,b.y,0,b.w/getW,b.h/ getH)
		--love.graphics.rectangle("fill",b.x,b.y,b.w,b.h)

		if b.type == players[i] then
			local centreX,centreY = fontBase:getWidth(players[i]["name"]) , fontBase:getHeight(players[i]["name"])
			love.graphics.print({{255,255,255}, ""..players[i]["name"]},b.x + (b.w - centreX) / 2 ,b.y+(b.h-centreY)/2, 0)
		elseif b.type == roles[i-#players] then
			local centreX ,centreY= fontBase:getWidth(roles[i-#players]["name"]),fontBase:getHeight(roles[i-#players]["name"])
			love.graphics.print({{255,255,255}, ""..roles[i-#players]["name"]}, b.x+ (b.w- centreX )/ 2,b.y+(b.h-centreY)/2, 0)

		end
	end
end
function Pregame.keypressed( key)
end

function Pregame.mousepressed( x, y, button, istouch, presses)
	--print(istouch)
	--print(s)
	for i=1,#bouttons do
		if objectInCollide(mouse,bouttons[i])  then
			bouttons[i].fonction(bouttons[i].parametre)
			break
		end
	end
	if objectInCollide(mouse,s) then
		collide = true
		ySelectedPoint = mouse.y 

	end	

end
function Pregame.mousereleased(  )
	if objectInCollide(mouse,s) then
		collide = false
	end
end
return Pregame