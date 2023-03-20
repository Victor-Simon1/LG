local Statistique = {}

function Statistique.load()
	affichage = "statistique"
    bouttons = {}
    MyButton("boutonRetour","boutonRetour",512,300,10,10,"nil",aff,"menu",false)
    MyButton("boutonQuitter","boutonParametre",512,400,10,10,nil,quitter,"quitter")

end



return Statistique