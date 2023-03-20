local Parametre = {}

function Parametre.load()
	affichage = "parametre"
    bouttons = {}
    MyButton("boutonRetour","boutonRetour",512,500,300,50,"nil",aff,"menu",false)
    MyButton("boutonQuitter","boutonParametre",512,570,300,50,nil,quitter,"quitter")
    img = love.graphics.newImage("Images/imgProf.png")
    imgH,imgW = img:getHeight(),img:getWidth()
end


function Parametre.update( ... )
	getW = love.graphics.newImage("Images/boutonBasique.png"):getWidth()
	getH = love.graphics.newImage("Images/boutonBasique.png"):getHeight()
end

function Parametre.draw( ... )
	love.graphics.draw(img,200,100,0,700/ imgW,300/ imgH)
	for i=1,#bouttons do
		b = bouttons[i]
		love.graphics.draw(b.img ,b.x,b.y,0,b.w /getW,b.h  / getH)
	end
end
function Parametre.mousepressed( ... )
	for i=1,#bouttons do
		if objectInCollide(mouse,bouttons[i])  then
			bouttons[i].fonction(bouttons[i].parametre)
			break
		end
	end
end
return Parametre