local Gameover = {}
getW = love.graphics.newImage("Images/boutonBasique.png"):getWidth()
getH = love.graphics.newImage("Images/boutonBasique.png"):getHeight()
function Gameover.load()
	affichage = "gameover"
    bouttons = {}
    love.graphics.setFont(fontBase)
    phraseWin = "Le(s) vainqueur(s) est/sont le(s) "
  	MyButton("boutonRetour","boutonRetour",512,300,300,50,"nil",aff,"menu",false)
  	MyButton("boutonRejouer","boutonRejouer",512,200,300,50,"nil",aff,"pregame",false)
end
function Gameover.update()
	
end
function Gameover.draw()
	love.graphics.print({{1,0,0},phraseWin..vainqueur},512 - fontBase:getWidth(phraseWin..vainqueur) / 2 ,100,0)
	for i=1,#bouttons do
		b = bouttons[i]
		love.graphics.draw(b.img ,b.x,b.y,0,b.w /getW,b.h  / getH)
	end
end
function Gameover.keypressed()
end
function Gameover.mousepressed()
	for i=1,#bouttons do
		if objectInCollide(mouse,bouttons[i])  then
			bouttons[i].fonction(bouttons[i].parametre)
			break
		end
	end
end
return Gameover