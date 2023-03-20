
getW = love.graphics.newImage("Images/boutonBasique.png"):getWidth()
getH = love.graphics.newImage("Images/boutonBasique.png"):getHeight()
local Menu = {}



function Menu.load( )
	affichage = "menu"
  		bouttons = {}
  		local x = 300
  		local y = 50
  		MyButton("boutonJouer","boutonJouer",512,100,x,y,nil,aff,"pregame")
		MyButton("boutonParametre","boutonParametre",512,200,x,y,nil,aff,"parametre")
		MyButton("boutonStatistique","boutonStatistique",512,300,x,y,nil,aff,"stats")
		MyButton("boutonQuitter","boutonParametre",512,400,x,y,nil,quitter,"quitter")
end
function Menu.update( )
	
end
function Menu.draw(  )
	for i=1,#bouttons do
		b = bouttons[i]
		love.graphics.draw(b.img ,b.x,b.y,0,b.w / getW,b.h /getH)
	end
end
function Menu.keypressed( key )
	if key == "escape" then
		love.event.quit()
	end
end
function Menu.mousepressed()
	for i=1,#bouttons do
		if objectInCollide(mouse,bouttons[i])  then
			bouttons[i].fonction(bouttons[i].parametre)
			break
		end
	end
end
return Menu