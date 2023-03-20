local Game = {}




-----------------------
--objetRecupExte = {"plume",0.2,"pomme",0.4,"bouffe",0.8,"bois",0.95,"canne",0.6,"cuir",0.7}
--objetRecupMine = {"diamond",0.05,"or",0.3,"fer",0.6,"fil",0.4,"obsi",0.6}
function carre(n)
	return n*n
end

function affichageDonneJoueur(player)
	playerAffiche.affichage = false
	player.affichage = true
	playerAffiche = player
end
function choixCouple()
	if minute >= 20  and couple == false then
		c1 = love.math.random(1,#playersSelect)
		c2 = love.math.random(1,#playersSelect)
		while c2 == c1 do
			c2 = love.math.random(1,#playersSelect)
		end
		pCouple1 = playersSelect[c1]
		pCouple2 = playersSelect[c2]
		playersSelect[c1]["couple"] = true
		playersSelect[c2]["couple"] = true
		couple = true
		createMessage("Le couple a ete defini il est compose de "..pCouple1["name"].." et de "..pCouple2["name"])
	end

end

function attribRole()
	if minute >= 20 and role == false then
		for i=1,#playersSelect do
  			local n = love.math.random(#rolesSelect)
  			playersSelect[i]["role"] = rolesSelect[n] 
  			if rolesSelect[n]["camp"] == "Loup" then
  				Loup = Loup +1
  			elseif rolesSelect[n]["camp"] == "Village" then
  				Village = Village +1 
  			else
  				Neutre = Neutre + 1
  			end
  			table.remove(rolesSelect,n)
  		end
  		role = true
  		trierListe(playersSelect)
		createMessage("Les roles ont ete attribue","Infos")

	end
end
function collissionDeuxCercle(c1,c2)
	if math.sqrt(carre(c2["x"] - c1["x"]) + carre(c2["y"] - c1["y"])) < c1["r"] then
		return true
	end
	return false
end

function trierListe(liste)
	table.sort(liste, function(a,b)if a["role"]["name"] ~= "Non Attribue"  then return a["role"]["camp"] < b["role"]["camp"] end end )
end

function trierListeKills(liste)
		table.sort(liste, function(a,b) return a["kills"] > b["kills"]end )
end

function timer(dt)
	seconde = seconde + 1
	if seconde > 60 then
		seconde = 0
		minute = minute + 1
	end
	if minute >= 60 then
		minute = 0
		heure = heure + 1
	end
end

function setSpawnPlayers()
	local dX,dY = 150,1
	local c,d = 0,0
	for i=1,#playersSelect do
		for y=1,#playersSelect do
			if playersSelect[i]["name"] ~= playersSelect[y]["name"] then
				playersSelect[i]["connaissance"][playersSelect[y]["name"]] = 0
				playersSelect[i]["messageAffiche"][playersSelect[y]["name"]] = false
			end
		end
		if  dX * c + panels[4].x > panels[4].w then
			c = 0
			d = d + 100
		end
		playersSelect[i]["x"] = dX * c + panels[4].x
		c = c+ 1
		playersSelect[i]["y"] = dY * d
		playersSelect[i]["cercle"] = {x =playersSelect[i]["x"],y=playersSelect[i]["y"],r = 50 }
	end
end

function setTarget(player,player2)
	local tX = love.math.random(-50,50)
	local tY = love.math.random(-math.sqrt(2500 - (tX * tX)),math.sqrt(2500 - (tX * tX)))
	if player["minageCave"] == true and player["versCentre"] == true then
		limite = {x1= panels[4].x+panels[4].w / 2 - 120, x2= panels[4].x +panels[4].w / 2 + 120 ,y1 =panels[4].y + panels[4].h / 2 - 90  ,y2 = panels[4].y + panels[4].h / 2 + 90 }
		player["target"] = {x = player["x"]  + tX,y = player["y"]+tY}
	elseif  player["minageCave"] == true and player["versCentre"] == false then 
		player["target"] = {x =panels[4].x+panels[4].w / 2  ,y =panels[4].y + panels[4].h / 2}
		limite = {x1= panels[4].x+panels[4].w / 2 - 120, x2= panels[4].x +panels[4].w / 2 + 120 ,y1 =panels[4].y + panels[4].h / 2 - 90  ,y2 = panels[4].y + panels[4].h / 2 + 90 }
		player["versCentre"] = true
		createMessage(player["name"].." se dirige vers le centre","Infos")
	else
		limite = {x1= panels[4].x, x2= panels[4].x +panels[4].w ,y1 =panels[4].y ,y2 = panels[4].y + panels[4].h }
		player["target"] = {x = player["x"]  + tX,y = player["y"]+tY}
	end
	player["border"] = limite
	 local 	random = 0 

		if player["target"].x > player["border"].x2 then
		 	random = player["border"].x2  - player["target"].x 
		 	player["target"] = {x = player["border"].x2 - 15 ,y = player["y"]}
		elseif  player["target"].x < player["border"].x1 then
			random =  player["target"].x -  player["border"].x2 
			player["target"] = {x =  player["border"].x1 + 15,y = player["y"]} 
		end
		if player["target"].y > player["border"].y2 then
		 	random = player["border"].y2  - player["target"].y  
		 	player["target"] = {x = player["x"] ,y =  player["border"].y2 - 15}
		elseif player["target"].y < player["border"].y1 then
			random =   player["target"].y  - player["border"].y2  
			player["target"] = {x = player["x"] ,y =  player["border"].y1 + 15}
		end

	if couple == true and player["name"] == pCouple1["name"] then
		player["target"] = {x = pCouple2.x  - 5 ,y = pCouple2.y - 5}
	end
	if player2 then
		if player["connaissance"][player2["name"]] > 60 then
			player["target"] = {x = player2.x ,y = player2.y}
		end
	end
end

function movePlayer(player)
	local deplacement = 0.5
	if player["target"].x == nil then
		setTarget(player)
	elseif math.abs(math.sqrt(math.pow(player["target"].x - player.x,2) + math.pow(player["target"].y - player.y,2))) < 10 then
		setTarget(player)
	end
	
		if player["x"] > player["target"].x then
			player["x"] = player["x"] - deplacement
		elseif player["x"] < player["target"].x then
			player["x"] = player["x"] + deplacement
		end
		if player["y"] > player["target"].y then
			player["y"] = player["y"] - deplacement
		elseif player["y"] < player["target"].y then
			player["y"] = player["y"] + deplacement
		end
end
function estMinage( player )
	local objAjoute = false
	--Partue Haut
	if player["minageExte"] == false  then
		for i = 1,#objetRecupExte do
			if objAjoute == false then
				local random = math.random(0.1,100 ) 
				if random < objetRecupExte[i]["drop"] * 100 and random > objetRecupExte[i]["drop"] * 100 - 15 then
					ajoutDansInventaire(player,objetRecupExte[i])
					objAjoute = true 
					craftObject(player)
				end
			end
		end
		if minute > 20 then
			player["minageExte"]  = true
		end
	end
	if player["minageCave"] == false and player["minageExte"] == true then
		--Partie Cave
		for y = 1,#objetRecupMine do
			if objAjoute == false then
				local random = math.random(1,100)
				if random < objetRecupMine[y]["drop"] *100 then
					if objetRecupMine[y]["name"] == "obsi" and  player["tableEnchant"] == true then
						objAjoute = false
					else
						ajoutDansInventaire(player,objetRecupMine[y])
						objAjoute = true 
						craftObject(player)
					end
				end
			end
		end
		if #player["armure"] == 5 or minute >= 30 and heure == 1 then
		
			player["minageCave"]  = true
			if minute >= 30 and heure == 1 then
				TabObject[10] = {fer = 8,name = "plastronFer"}
			--	TabObject[11] = {fer = 4,name = "bottesFer"}
				craftObject(player)
				setEnchantement(player)
			end
		end

	end
end

function craftObject(player)
	local obj = true
	local trouve = false
	local objName = nil
	for i=1,#TabObject do
		local tabTemp = {}
	--	print(TabObject[i]["name"])
		if verifArmure(player,TabObject[i]["name"]) then
			for k,v in pairs(TabObject[i]) do
				trouve = false
				if obj == true then
					for case=1,#player["inventaire"] do
					--	print(player["inventaire"][case]["name"].." : "..k)
						if k ~= "name" and player["inventaire"][case]["nombre"] >= v and player["inventaire"][case]["name"] == k then
						--	print("ASSEZ".." : "..k)
							trouve = true
							table.insert(tabTemp,case)
							table.insert(tabTemp,v)
						elseif k ~= "name"  and player["inventaire"][case]["nombre"] < v and player["inventaire"][case]["name"] == k  then
						--	print("PAS ASSEZ".." : "..k)
							obj = false
						elseif k == "name" then
							trouve = true  
							objName = v
						end
					end
					if trouve == false then
						obj = false
						--print("JEN AI PAS : "..k)
					end
				end
				--print(obj)
			end
		else
			obj = false
		end
		if obj == true then
			--print("JE PEUX CRAFT")
			if objName == "plastronDiams"  or objName == "pantalonFer" or objName =="casqueFer" or objName == "botteDiams" or objName == "epeeFer" or objName == "plastronFer" or objName == "bottesFer"   then
				player["ptsProtection"] = player["ptsProtection"] + 0.5
				ajoutArmure(player,objName)
			else
				local objet = {}
				objet["name"] = objName
				if objName == "tableEnchant" then
					player["tableEnchant"] = true
				end
				ajoutDansInventaire(player,objet)
			end
			for p =1,#tabTemp do	
				if p % 2 == 1 then
					player["inventaire"][tabTemp[p]]["nombre"] =  player["inventaire"][tabTemp[p]]["nombre"] - tabTemp[p+1]
				end	
			end
			suppresionInventaire(player)
		else
			obj = true
		end
	end
end

function setEnchantement(player )
	if player["tableEnchant"] == true then
		for i=1,#player["armure"] do
			if player["armure"][i]["enchantement"] == "" then
				if player["armure"][i]["name"] == "epeeFer" then
					player["armure"][i]["enchantement"] = "Sharpness 1"
					player["epee"] = player["epee"] + 1 
				else 
					player["armure"][i]["enchantement"] = "Protection 1"
					player["ptsProtection"] = player["ptsProtection"] + 1 
				end
			end 
		end
	end

end
function suppresionInventaire(player)
	for i=1,#player["inventaire"] do
		if player["inventaire"][i] ~= nil  and player["inventaire"][i]["nombre"] == 0 then 
			table.remove(player["inventaire"],i)
		end
	end
end

function verifArmure(player,nomObj)
	for i=1,#player["armure"] do
		if nomObj == player["armure"][i]["name"] then
			return false
		end
	end
	return true 
end
function ajoutArmure(player,armure)
		local obj = {img = love.graphics.newImage("Images/"..armure..".png"),name = armure,enchantement = ""}
    	table.insert(player["armure"],obj)
end
function ajoutDansInventaire(player,liste)
	local objTrouve = false
	local z = 1
	local objAjoute = false
	while objTrouve == false and z <= #player["inventaire"] do
		if liste["name"] == player["inventaire"][z]["name"] then
			objTrouve = true
		end
		z = z +1 
	end
	if objTrouve == true then
		objAjoute = true
		player["inventaire"][z-1]["nombre"] = player["inventaire"][z-1]["nombre"]  +1 
	else
		objAjoute = true
		createObject(liste["name"],player,"inventaire")
	end
end
function EnnemeieAndAllieInCercle(p)
	for i=1,#playersSelect do
		if p["name"] ~= playersSelect[i]["name"] then
			if p["couple"] == false then
				if objectInCercle(playersSelect[i],p["cercle"]) and p["role"]["camp"] ~=  playersSelect[i]["role"]["camp"] then
					p["ennemie"] = p["ennemie"] + 1
				elseif objectInCercle(playersSelect[i],p["cercle"]) and p["role"]["camp"] ==  playersSelect[i]["role"]["camp"] then
					p["allie"] = p["allie"] + 1
				end
			else
				if objectInCercle(playersSelect[i],p["cercle"]) and p["role"]["camp"] ~=  playersSelect[i]["role"]["camp"] and playersSelect[i]["couple"] == false then
					p["ennemie"] = p["ennemie"] + 1
				elseif objectInCercle(playersSelect[i],p["cercle"]) and p["role"]["camp"] ==  playersSelect[i]["role"]["camp"] or  playersSelect[i]["couple"] == true then
					p["allie"] = p["allie"] + 1
				end
			end
		end
	end
end
function killSomeone(p1,p2)
	local nbJoueurInCercle = 0 
	local coup = p1["pvp"] / (p2["ptsProtection"]*20)
 	if p1["couple"] == false and p2["couple"] == false or p1["couple"] == false and p2["couple"] == true or p1["couple"] == true and p2["couple"] == false then
		if p1["role"]["camp"] == "Village" then
			EnnemeieAndAllieInCercle(p1)
			if p1["connaissance"][p2["name"]] > 60 and objectInCercle(p2,p1["cercle"]) or p1["estAttaque"] == p2["name"] then
				p2["vie"] = p2["vie"] -coup
				p2["estAttaque"] = p1["name"]
				if p2["couple"] then
					pCouple1["estAttaque"] = p1["name"]
					pCouple2["estAttaque"] = p1["name"]
				end
			elseif p1["couple"] and  p1["allie"] == 1 and p1["ennemie"] <= 2   then
				p2["vie"] = p2["vie"] - coup
				p2["estAttaque"] = p1["name"]

			end	
		elseif p1["role"]["camp"] == "Loup" then
			p1["ennemie"] = 0
			p1["allie"] = 0
			EnnemeieAndAllieInCercle(p1)
			if objectInCercle(p2,p1["cercle"]) and p2["role"]["camp"] ~= "Loup"  and p1["allie"] + 1 >= p1["ennemie"] or p1["estAttaque"] == p2["name"] then
				p2["vie"] = p2["vie"] - coup
				p2["estAttaque"] = p1["name"]
				if p2["couple"] then
					pCouple1["estAttaque"] = p1["name"]
					pCouple2["estAttaque"] = p1["name"]
				end
			end
		else 
			p1["ennemie"] = 0
			p1["allie"] = 0
			EnnemeieAndAllieInCercle(p1)
			if objectInCercle(p2,p1["cercle"])and p1["ennemie"] == 1 or p1["estAttaque"] == p2["name"] then
				p2["vie"] = p2["vie"] - coup
				p2["estAttaque"] = p1["name"]
				if p2["couple"] then
					pCouple1["estAttaque"] = p1["name"]
					pCouple2["estAttaque"] = p1["name"]
				end
			end
		end
	end
	if p2["vie"] < 0 then
		p1["estAttaque"] = nil
		p2["mort"] = true
		createMessage(p2["name"].." est mort. Il etait "..p2["role"]["name"],"mort")
		p1["kills"] = p1["kills"] + 1
		if p1["role"]["camp"] == "Loup" then
			local  random = love.math.random(0,100)
			if random > 75  and infection == false then
				p2["vie"] = 20
				p2["x"] = p2["border"]["x1"] +10
				p2["y"] = p2["border"]["y1"] +10
				p2["role"]["camp"] ="Loup"
				p2["mort"] = false
				Loup = Loup + 1 
				infection = true
				trierListe(playersSelect)
			elseif p2["role"]["name"] == "Ancien" and vieUtilise == false then
				p2["vie"] = 20
				p2["x"] = p2["border"]["x2"] -10
				p2["y"] = p2["border"]["y1"] +10
				p2["role"]["camp"] ="Loup"
				p2["mort"] = false
				vieUtilise =  true
			end
		elseif p1["role"]["name"] == "Voleur" then
			p1["role"]["name"] = p2["role"]["name"]
			p1["role"]["camp"] = p2["role"]["camp"]
			trierListe(playersSelect)
		end
 		if p2["couple"] == true  then
			pCouple2["mort"] = true
			pCouple1["mort"] = true
			if pCouple1["name"] ~= p2["name"] then
				createMessage(pCouple1["name"].." est mort de chagrin. Il etait "..pCouple1["role"]["name"],"mort")
				if pCouple1["role"]["camp"] == "Village" then
					Village = Village - 1 
				elseif pCouple1["role"]["camp"] == "Village" then
					Loup = Loup - 1 
				else
					Neutre = Neutre - 1
				end
			else
				createMessage(pCouple2["name"].." est mort de chagrin. Il etait "..pCouple2["role"]["name"],"mort")
				if pCouple2["role"]["camp"] == "Village" then
					Village = Village - 1 
				elseif pCouple2["role"]["camp"] == "Loup" then
					Loup = Loup - 1 
				else
					Neutre = Neutre - 1
				end
			end
		end
		if p2["role"]["camp"] == "Village" then
			Village = Village - 1 
		elseif p2["role"]["camp"] == "Loup" then
			Loup = Loup - 1 
		else
			Neutre = Neutre - 1
		end
	end
end

function detectionVoyante(player)
	if episode[episodes]["sorciere"] == false and episodes % 2 == 1 then
		local random = love.math.random(1,#playersSelect)
		if player["name"] ~= playersSelect[random]["name"] then
			if playersSelect[random]["role"]["camp"] == "Loup" or playersSelect[random]["role"]["camp"] == "Neutre"then
				player["connaissance"][playersSelect[random]["name"]] = 100
			end
			createMessage(player["name"].." a decouvert que "..playersSelect[random]["name"].." ete "..playersSelect[random]["role"]["name"],"infos")
			episode[episodes]["sorciere"] = true
		else
			if random == #playersSelect then
				random = random -1 
			else 
				random = random + 1
			end
			if playersSelect[random]["role"]["camp"] == "Loup" or playersSelect[random]["role"]["camp"] == "Neutre"then
				player["connaissance"][playersSelect[i]["name"]] = 100
			end
				createMessage(player["name"].." a decouvert que "..playersSelect[random]["name"].." ete "..playersSelect[random]["role"]["name"],"infos")
			episode[episodes]["sorciere"] = true
		end
	end
end

function detectionMontreur(player)
	if episodes % 2 == 1 and episode[episodes]["montreur"]  == false then
		for i=1,#playersSelect do
			if playersSelect[i]["role"]["camp"] == "Loup" then
				createMessage("Grrrrrr","Infos")
			end
		end
	 	episode[episodes]["montreur"] = true
	end
end
function setEpisode()
	if heure == 0 then
		episodes = math.floor(minute / 10 + 1)
	elseif heure == 1 then
		episodes =  math.floor((minute + 60)/10 + 1)
	elseif heure == 2 then
		episodes = math.floor((minute + 120)/10 + 1)
	end
	--print(episodes)
end
function mangerGapple(player)
	for i=1,#player["inventaire"] do
		if player["inventaire"][i] ~= nil and player["inventaire"][i]["name"] == "pommeOr" and player["vie"] < 18 then
			player["inventaire"][i]["nombre"]  = player["inventaire"][i]["nombre"]-1 
			player["vie"] = player["vie"] + 2
			suppresionInventaire(player)
		end
	end
end
function victory()
	local nb = 0
	local v,l,n = 0,0,0
	for i=1,#playersSelect do
		if playersSelect[i]["mort"] == false then
			nb = nb + 1
			if playersSelect[i]["role"]["camp"] == "Village" then
				v = v + 1
			elseif playersSelect[i]["role"]["camp"] == "Loup" then
				l =l + 1
			elseif playersSelect[i]["role"]["camp"] == "Neutre" then
				n = n+1
			end
		end
	end

	if l == 0 and n == 0 then
		aff("gameover")
		roles = {}
		players = {}
		messages = {}
		panels = {}
		return "village"
	elseif v == 0 and n == 0 then
		aff("gameover")
		roles = {}
		players = {}
		messages = {}
		panels = {}
		return "loup"
	elseif l == 0 and v == 0 and n  == 1 then
		aff("gameover")
		roles = {}
		players = {}
		messages = {}
		panels = {}
		return "neutre"
	elseif nb == 2 and pCouple1["mort"] == false and pCouple2["mort"] == false then
		aff("gameover")
		roles = {}
		players = {}
		messages = {}
		panels = {}
		return "couple"
	end
	return ""
end
function Game.load( ... )
	if choosePlayer() ~= chooseRoles() or #playersSelect < 10  then
			playersSelect = {}
			rolesSelect = {}
  	else
  			affichage = "game"
  			couple = false
			inventaire = love.graphics.newImage("Images/boutonBasique.png")
			seconde = 0
			minute = 0
			heure = 0
			c1,c2 = 0,0
			game = true
			role = false
			affPause = false
			pCouple1 = nil
			pCouple2 = nil
			tempNbJouer = 0
  			bouttons = {}
  			love.graphics.setFont(font)
  			trierListe(playersSelect)
  			createPanel(0,0,150,768,true)
  			createPanel(0,0,150,768,false)
  			createPanel(0,0,150,768,false)
  			createPanel(151,0,1024-150,450,true)
  			createPanel(151,451,1024-150,768-450,true)
  			setSpawnPlayers()
			local height = 768 / #playersSelect 
		for i=1,#playersSelect do
			MyButton("boutonBasique","boutonBasique",100,(i-1) * 25,200,25,playersSelect[i],affichageDonneJoueur,playersSelect[i],false) 
		end
		playerAffiche = playersSelect[1]
		playerAffiche.affichage = true
		limite = {}
		infection = false
		vieUtilise = false
		TabObject = {}
		TabObject[1] = {diamant = 4,name = "botteDiams"}
		TabObject[2] = {diamant = 8,name = "plastronDiams"}
		TabObject[3] = {fer = 5,name = "casqueFer"}
		--TabObject[4] = {fer = 8,name = "plastronFer"}
		TabObject[4] = {fer = 7,name = "pantalonFer"}
	--	TabObject[6] = {fer = 4,name = "bottesFer"}
		TabObject[5] = {pomme = 1, gold= 8,name = "pommeOr"}
		TabObject[6] = {livre = 1 ,diamant = 2,obsi = 4,name = "tableEnchant"}
		TabObject[7] = {canne = 3,cuir = 1,name = "livre"}
		TabObject[8] = {baton = 1, fer = 2,name = "epeeFer"}
		TabObject[9] = {bois = 2 ,name = "baton"}	
	end
	episode = {}
	for i=1,20 do
		episode[i] = {montreur = false, sorciere = false}
	end
end

function Game.update( dt )
	if game == true then
		timer(dt)
		attribRole()
		choixCouple()
		setEpisode()
		for i=1,#playersSelect  do
			local p = playersSelect[i]
			if p["mort"] == false then
				mangerGapple(p)
				if p["role"]["name"] == "Voyante Bavarde" then
					detectionVoyante(p)
				elseif p["role"]["name"] == "Montreur d'Ours" then 
					detectionMontreur(p)
				end
				p["cercle"] = {x =p["x"] + p["w"] / 2 ,y=p["y"] +p["h"] / 2,r = 40 }
				if (p["minageExte"] == false or p["minageCave"] == false )and seconde >20 and seconde < 30 and p["minage"] <=4  then
					estMinage(p)
					setEnchantement(p)
					p["minage"] = p["minage"] + 1 
					--print("here")
				end
				if seconde <5 then
					p["minage"] = 0
				end
				movePlayer(p)
				for y=#playersSelect,1,-1 do
					p2 = playersSelect[y]
						if role == true and p["mort"] == false and p2["mort"] == false then
							if objectInCercle(p,p2["cercle"]) and p["name"] ~= p2["name"] then
								p["connaissance"][p2["name"]] = p["connaissance"][p2["name"]] + 2 / p["guessrole"]
								if p["connaissance"][p2["name"]] > 40 and p["messageAffiche"][p2["name"]] == false and p["role"]["camp"] == "Village"  then
									if p["couple"] == false and p2["couple"] == false or p["couple"] == true and p2["couple"] == false or p["couple"] == false and p2["couple"] == true then
										createMessage(p["name"].." a des soupçon sur "..p2["name"])
										p["messageAffiche"][p2["name"]] = true
									end
								end
								if p2["role"]["camp"] ~= p["role"]["camp"] then
									p["ennemie"] = p["ennemie"] +1 
								else 
									p["allie"] = p["allie"] + 1
								end
							end 
							if p["minageCave"]  and p2["minageCave"] and p["name"] ~= p2["name"]  then
								killSomeone(p,p2)
							end
						end
					end
				end
			end
			if role == true then
				vainqueur = victory()
			end
	end
end

function Game.draw( ... )
	if game == true then
		local a,affichageLoup,affichageNeutre, affichageVillage = 0,false,false,false
		local tempCompt = 1 
		local r,v,b =0,0,0
		for i=1,#panels do
			local  p = panels[i]
			if p.isVisible then
				love.graphics.setColor(0.1*i,0.2*i,0.1*i)
				love.graphics.rectangle("fill",p.x,p.y,p.w,p.h)
				love.graphics.print({{0,0,0},heure.."-"..minute.."-"..seconde},600,0,0)
			end
		end
			love.graphics.setColor(1,1,1)
		for i=#messages,1,-1 do
			if panels[5].y  + panels[5].h - 10 - 10 * tempCompt > panels[5].y and i > #messages  - 20 then
				love.graphics.rectangle("line",panels[5].x ,panels[5].y  + panels[5].h - 10 - 15 * tempCompt, font:getWidth(messages[i]["contenu"]),font:getHeight(messages[i]["contenu"]))
				love.graphics.print({{1,0,0},messages[i]["contenu"]},panels[5].x,panels[5].y  + panels[5].h - 10 - 15 * tempCompt)
			end
			tempCompt = tempCompt + 1
		end
		for i=1,#playersSelect do
			local p = playersSelect[i]
			--------------MESSAGE BOX--------------

			--------------GESTION COULEURS--------------
			if p["role"] ~= nil then
				if p["role"]["camp"] == "Loup" then
					r,v,b = 255,0,0
				elseif p["role"]["camp"] == "Neutre" then
					r,v,b = 1, 196 /255, 51/255
				elseif p["role"]["camp"] == "Village" then
					r,v,b = 51/255,187/255,1
				end
			end
			if p["couple"] == true then
				r1,v1,b1 = r,v,b
				r,v,b = 212/255, 85/255, 247/255
			end
			if p["mort"] then
				r,v,b = 90/255,90/255,90/255
			end
			if panels[1].isVisible then
				if p["role"] ~= nil then
					if p["role"]["camp"] == "Loup" and affichageLoup == false then
						love.graphics.print({{255,0,0}, "Loup :"}, panels[1].x +10,panels[1].y +20 * i+a, 0)
						a = a +20
						affichageLoup = true
					elseif p["role"]["camp"] == "Neutre" and affichageNeutre == false then
						love.graphics.print({{255,0,0}, "Neutre :"}, panels[1].x +10 ,panels[1].y +20 *i+a, 0)
						a = a +20
					affichageNeutre = true
					elseif p["role"]["camp"] == "Village" and affichageVillage == false then
						love.graphics.print({{255,0,0}, "Village :"}, panels[1].x +10 ,panels[1].y +20 * i+a, 0)
						a = a +20
						affichageVillage = true
					end
				end
				love.graphics.print({{r,v,b}, "-"..p["name"].." : "..p["vie"]}, panels[1].x +30 ,panels[1].y +20 * i+a, 0)
			end
			if panels[2].isVisible then
				love.graphics.print({{r,v,b},i.."  "..p["name"].." : "..p["kills"]},panels[1].x +10,panels[1].y +20 * i,0)
			--	print(p["name"].." : "..p["kills"])
			end
			if panels[3].isVisible and p["role"] ~= nil then
				love.graphics.print({{r,v,b},i.."  "..p["name"].." :\n "..p["role"]["name"]},panels[1].x +10,panels[1].y +20 * i,0)
			end
			if p["vie"] > 0 and p["mort"] == false then
				if not p["minageCave"]  then 
					love.graphics.setColor(107/255,107/255,107/255)
				end
				love.graphics.draw(p["imgHead"],p["x"],p["y"],0, p["w"] / p["imgHead"]:getWidth(), p["h"] / p["imgHead"]:getHeight())
				love.graphics.setColor(1,1,1)
					love.graphics.setColor(r,v,b)
				love.graphics.rectangle("line",p["x"] ,p["y"]  , p["w"] ,p["h"] )
				love.graphics.setColor(1,1,1)
				love.graphics.circle("line",p["cercle"].x,p["cercle"].y,p["cercle"].r)
			end
			if p["couple"]  == true then
					r,v,b = r1,v1,b1
			end
		end
	elseif game == "pause" then
		love.graphics.setColor(0,0,1)
		love.graphics.rectangle("fill",0 ,0,1024,768)
		love.graphics.setColor(1,1,1)	
		love.graphics.draw(playerAffiche["imgHead"],250,50,0,50/playerAffiche["imgHead"]:getWidth(),50/playerAffiche["imgHead"]:getHeight())	
		love.graphics.print({{255,255,255}, "Nom : "..playerAffiche["name"]},250 ,120, 0)
		love.graphics.print({{255,255,255}, "Role : "..playerAffiche["role"]["name"]},250 ,142, 0)
		love.graphics.print({{255,255,255}, "Kill(s) : "..playerAffiche["kills"]},250 ,164, 0)
		love.graphics.print({{255,255,255}, "Connaissance"},450 ,50, 0)
		love.graphics.print({{255,255,255}, "Suspecte par"},600 ,50, 0)

		for i=1,#bouttons do
			b = bouttons[i]
			love.graphics.draw(b.img,b.x,b.y,0,b.w /getW,b.h /getH)
	
			local centreX,centreY = font:getWidth(b.parametre["name"]) , font:getHeight(b.parametre["name"])
			love.graphics.print({{255,255,255}, ""..b.parametre["name"]},b.x + (b.w - centreX) / 2  ,b.y+(b.h-centreY)/2, 0)
			if b.parametre.affichage == true then
				local temp = 1
				for y=1,#playersSelect do
					if playersSelect[y]["name"] ~= b.parametre["name"] then
						love.graphics.print({{255,0,0},string.format(playersSelect[y]["name"].." : %.2f",b.parametre["connaissance"][playersSelect[y]["name"]])},450 ,75 + 12* temp , 0)
						love.graphics.print({{255,0,0}, string.format(playersSelect[y]["name"].." : %.2f",playersSelect[y]["connaissance"][playerAffiche["name"]])},600 ,75 + 12* temp , 0)
						temp = temp  + 1 
					end
				end
				for z=1,#playerAffiche["armure"] do
					love.graphics.draw(playerAffiche["armure"][z]["img"],500,350 + z *50,0,50/playerAffiche["armure"][z]["img"]:getWidth(),50/playerAffiche["armure"][z]["img"]:getHeight())
				
					love.graphics.print({{255,255,255}, ""..playerAffiche["armure"][z]["enchantement"]},550,350 + z*50, 0)
				end
				for z1=1,#playerAffiche["inventaire"] do
					love.graphics.draw(playerAffiche["inventaire"][z1]["img"],250,150 + z1 *50,0,50/playerAffiche["inventaire"][z1]["img"]:getWidth(),50/playerAffiche["inventaire"][z1]["img"]:getHeight())
					love.graphics.print({{255,255,255}, ""..playerAffiche["inventaire"][z1]["nombre"]},300,150 + z1*50, 0)
				end
			end
		end
	end
	if game == "false" then
		love.graphics.print({{1,0,0},"Victoire des "..victory()},500,200)
	end
end

function Game.mousepressed()
	if game == "pause" then 
		for i=1,#bouttons do
			if objectInCollide(mouse,bouttons[i])  then
				bouttons[i].fonction(bouttons[i].parametre)
				break
			end
		end
	end
end

function Game.keypressed(key)
	if key == "kp1" then
		panels[1].isVisible = true
		panels[2].isVisible =false
		panels[3].isVisible =false
		trierListe(playersSelect)
	elseif key == "kp2" then
		panels[1].isVisible = false
		panels[2].isVisible =true
		panels[3].isVisible =false
		trierListeKills(playersSelect)

	elseif key == "kp3" then
		panels[1].isVisible = false
		panels[2].isVisible =false
		panels[3].isVisible =true
	elseif key == "o" and game == true then
		game = "pause"
	elseif key == "o" and game == "pause" then
		game = true
	end
end
return Game