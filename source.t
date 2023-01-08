%KolbyChong_KamronZaidi_finalProjectJune12.t
%Created by: Kolby Chong, Kamron Zaidi
%Last edit: June 12, 2017
%Title menus code + Game code for final project game (Shadow Mage)

%Initialize window size and type
setscreen ("graphics:1300;650")
View.Set ("offscreenonly")

%Used for main menu's click cooldown
var clickCooldown : int := 0

%Used for each respective screen's conditions
var menuButton, playButton, instructionsButton, aboutButton : boolean

%Define each variable for each menu background
var menuBG, instructionsBG, aboutBG, exitBG : int

%Define variables for Shadow Mage title and bottom right message on main menu and the About Page text
var title, madeFor, aboutInfo : int

%Define variables for Instruction Menu hover tabs
var rules, controls, tips : int

%Assign each background's image
menuBG := Pic.FileNew ("Shadow Mage Title Screen.bmp") %Main menu
instructionsBG := Pic.FileNew ("Instructions.bmp") %Instructions menu
aboutBG := Pic.FileNew ("About.bmp") %About menu
exitBG := Pic.FileNew ("Exit.bmp") %Exit screen

%Creates a sprite for the Rules hover tab
rules := Pic.FileNew ("Rules Full.bmp") %Assign image
rules := Pic.Scale (rules, 550, 325) %Scale
var spriteRules : int := Sprite.New (rules) %Create sprite

%Creates a sprite for the Controls hover tab
controls := Pic.FileNew ("Controls Full.bmp") %Assign image
controls := Pic.Scale (controls, 550, 325) %Scale
var spriteControls : int := Sprite.New (controls) %Create sprite

%Creates a sprite for the Tips hover tab
tips := Pic.FileNew ("Tips Full.bmp") %Assign image
tips := Pic.Scale (tips, 575, 292) %Scale
var spriteTips : int := Sprite.New (tips) %Create sprite

%Set image for the Shadow Mage title
title := Pic.FileNew ("Shadow_Mage_Title_V4.bmp")
title := Pic.Scale (title, 700, 100)

%Set image for the 'Made For' object
madeFor := Pic.FileNew ("Menu Object.bmp")
madeFor := Pic.Scale (madeFor, 400, 50)

%Set image for the About Menu text
aboutInfo := Pic.FileNew ("About Page Info.bmp")
aboutInfo := Pic.Scale (aboutInfo, 600, 250)

%Set sprite for the main player model
var picShadowMage : int := Pic.FileNew ("Shadow Mage.bmp")
picShadowMage := Pic.Scale (picShadowMage, 50, 50)
var spriteShadowMage : int := Sprite.New (picShadowMage)
Sprite.SetPosition (spriteShadowMage, maxx div 2, maxy div 2, true)
%Apparently needed or else program doesn't work
Sprite.Show (spriteShadowMage)
Sprite.Hide (spriteShadowMage)

%Set sprite for each basic enemy
var picSnake : int := Pic.FileNew ("Snake Enemy.bmp")
picSnake := Pic.Scale (picSnake, 50, 50)
var spriteSnake : int := Sprite.New (picSnake)

%Set sprite for each advanced enemy
var picNinja : int := Pic.FileNew ("Night Ninja Enemy.bmp")
picNinja := Pic.Scale (picNinja, 50, 50)
var spriteNinja : int := Sprite.New (picNinja)

%Set sprite for the special projectile pre-exploded (AoE Portal/Q ability)
var picSpecialProjectile : int := Pic.FileNew ("Special Projectile.bmp")
picSpecialProjectile := Pic.Scale (picSpecialProjectile, 20, 20)
var spriteSpecial : int := Sprite.New (picSpecialProjectile)

%Set sprite for the exploded special projectile (AoE Portal/Q ability)
var picPortal : int := Pic.FileNew ("Portal.bmp")
var spritePortal : int := Sprite.New (picPortal)

%Fonts
var font : int := Font.New ("serif:12")
var fontHeader : int := Font.New ("serif:24")
var fontTitle : int := Font.New ("serif:36")

%Variables and Constants for Player Movement, Health, Mana and Score
var playerX : int := maxx div 2
var playerY : int := maxy div 2
var health, mana : int := 100
var score, enemyKilled : int := 0
var chars : array char of boolean
var manaRegenCount : int := 0
const PLAYER_SPEED := 4
const MANA_REGEN : int := 1

%Variables and Constants to get Highscore
var highscore : int
const pathName : string := "Highscore.txt"
var file : int
var beatHighScore : boolean := false

%Variables and Constants for Enemy Movement, Creation, Health, Sprite, and Type (special vs normal)
var monsterX, monsterY, monsterHealth, arraySprites : flexible array 1 .. 4 of int
var monsterSpecial : flexible array 1 .. 4 of boolean
var previousMonsterUpper : int
var difficulty : real := 4
var monsterDistance, monsterTravelTime : real
var monsterModifierX, monsterModifierY : real
const DIFFICULTY_RATE : real := 0.0025
const MONSTER_HEALTH : int := 2
const MONSTER_SPEED := 1
const MONSTER_SPECIAL_SPEED := 2

%Variables for firing projectiles
var mouseX, mouseY, mouseStat : int
var projectileModifierX, projectileModifierY : real := 0
var projectileTravelTime, projectileDistance : real
var oldPlayerX, oldPlayerY : int := 0
var reloadCount : int := 0
var ballCollision : boolean := false
const PROJECTILE_SPEED : real := 20
const RELOAD_CAP : int := 25
const PROJECTILE_DAMAGE : int := 1


%Variables for firing special projectile
var special : boolean := false
var specialX, specialY, specialStat : int
var specialModifierX, specialModifierY : real := 0
var specialTravelTime, specialDistance : real
var oldSpecialPlayerX, oldSpecialPlayerY : int := 0
var specialReloadCount : int := 0
var specialCollision : boolean := true
var explosion : boolean := false
var explosionX, explosionY : int := 0
var explosionCount : int := 0
const EXPLOSION_COUNT_MAX : int := 50
const SPECIAL_PROJECTILE_SPEED : real := 20
const SPECIAL_RELOAD_CAP : int := 25
const MANA_COST_SPECIAL : int := 40

%Variables and constants for teleport spell
var teleportCooldown : int := 0
var targetX, targetY, targetMouseStat : int
const MANA_COST_TELEPORT : int := 10

%Variables for knockback spell
var knockback : boolean := false
var knockbackQuadraticsA, knockbackQuadraticsB, knockbackLineYIntercept, knockbackQuadraticsC, knockbackLineSlope : real
var r : real := 0
var knockbackPlayerX, knockbackPlayerY : int
const RADIUS_MAX : int := 300
const MANA_COST_KNOCKBACK : int := 30

%Variables for heal
var heal : boolean := false
var healRadiusMod : int := 0
var healPlayerX, healPlayerY : int
const HEAL : int := 5
const MANA_COST_HEAL : int := 70



%Procedure for main menu
procedure openMenu
    %Change any button statuses so that only main menu is true
    instructionsButton := false
    aboutButton := false
    playButton := false
    menuButton := true
    %Display images on screen
    cls
    Pic.Draw (menuBG, 0, 0, picMerge)
    Pic.Draw (title, 300, 525, picMerge)
    Pic.Draw (madeFor, 800, 70, picMerge)
    View.Update
end openMenu

%Procedure for instructions menu
procedure openInstructions
    %Change any button statuses so that only instructions menu is true
    menuButton := false
    instructionsButton := true
    %Display images on screen
    cls
    Pic.Draw (instructionsBG, 0, 0, picMerge)
    View.Update
end openInstructions

%Procedure for about menu
procedure openAbout
    %Change any button statuses so that only about menu is true
    menuButton := false
    aboutButton := true
    %Display images on screen
    cls
    Pic.Draw (aboutBG, 0, 0, picMerge)
    Pic.Draw (aboutInfo, maxx div 2 - 300, maxy div 2 - 150, picMerge)
    View.Update
end openAbout

procedure openScores
    
    drawfillbox (0, 0, maxx - 201, maxy, 67)
    Music.PlayFileStop
    %Hide sprites
    Sprite.Hide (spriteShadowMage)
    Sprite.Hide (spritePortal)
    Sprite.Hide (spriteSpecial)
    for endGame : 1 .. upper (monsterX)
        Sprite.Hide (arraySprites (endGame))
    end for
        %Tell user they lost
    Font.Draw ("YOUR LEGACY HAS ENDED", maxx div 2 - 400, maxy div 2 - 25, fontTitle, black)
    delay (2000)
    for i : 1 .. 1000
        drawfilloval (maxx div 2 - 100, maxy div 2, i, i, black)
        delay (1)
    end for
        
    %Show round reached, enemies killed, and final score
    Font.Draw ("Maximum Round Reached: " + intstr (difficulty div 1 - 3), maxx div 2 - 200, maxy div 2 - 25, fontHeader, white)
    Music.PlayFile ("Slam Sound Effect.mp3")
    
    drawfillbox (maxx div 2 - 200, maxy div 2 - 25, maxx, maxy, black)
    Font.Draw ("Maximum Round Reached: " + intstr (difficulty div 1 - 3), maxx div 2 - 200, maxy div 2, fontHeader, white)
    Font.Draw ("Enemies Killed: " + intstr (enemyKilled), maxx div 2 - 200, maxy div 2 - 25, fontHeader, white)
    Music.PlayFile ("Slam Sound Effect.mp3")
    
    drawfillbox (maxx div 2 - 200, maxy div 2 - 25, maxx, maxy, black)
    Font.Draw ("Maximum Round Reached: " + intstr (difficulty div 1 - 3), maxx div 2 - 200, maxy div 2 + 25, fontHeader, white)
    Font.Draw ("Enemies Killed: " + intstr (enemyKilled), maxx div 2 - 200, maxy div 2, fontHeader, white)
    Font.Draw ("Final Score: " + intstr (score * 5), maxx div 2 - 200, maxy div 2 - 25, fontHeader, white)
    Music.PlayFile ("Slam Sound Effect.mp3")
    
    %Check the high score, and if the highscore is less than current score, replace the high score with this score.
    open : file, pathName, get
    get : file, highscore
    close : file
    
    if score > highscore then
        beatHighScore := true
        open : file, pathName, get, put
        put : file, score
        highscore := score
        close : file
    else
        beatHighScore := false
    end if
    
    %Display high score
    drawfillbox (maxx div 2 - 200, maxy div 2 - 25, maxx, maxy, black)
    Font.Draw ("Maximum Round Reached: " + intstr (difficulty div 1 - 3), maxx div 2 - 200, maxy div 2 + 50, fontHeader, white)
    Font.Draw ("Enemies Killed: " + intstr (enemyKilled), maxx div 2 - 200, maxy div 2 + 25, fontHeader, white)
    Font.Draw ("Final Score: " + intstr (score * 5), maxx div 2 - 200, maxy div 2, fontHeader, white)
    Font.Draw ("High Score: " + intstr (highscore * 5), maxx div 2 - 200, maxy div 2 - 25, fontHeader, white)
    %Display if high score is beat
    if beatHighScore = true then
        Font.Draw ("NEW HIGH SCORE!", maxx div 2 - 200, maxy div 2 - 60, fontHeader, brightred)
    end if
    Music.PlayFile ("Slam Sound Effect.mp3")
    
    %Click enter to continue
    Font.Draw ("Click enter to continue...", maxx div 2 - 200, maxy div 2 - 100, fontHeader, white)
    
    %Check what button is being pressed
    loop
        Input.KeyDown (chars)
        %If "ENTER", go to menu
        if chars (KEY_ENTER) then
            openMenu
            Music.PlayFileLoop ("Realm of the Mad God Soundtrack - Title BGM.mp3")
            exit
        %If 'm', reset highscore in .txt file back to 0
        %DEBUGGING ONLY%
        elsif chars ('m') then
            open : file, pathName, put
            put : file, 0
            close : file
        end if
    end loop
end openScores

%Procedure for exit menu + animation
procedure openExit
    %Display images on screen
    cls
    Pic.Draw (exitBG, 0, 0, picMerge)
    View.Update
    delay (2500)
    
    %Closing animation
    for i : 1 .. 324
        delay (4)
        drawfillbox (0, maxy, maxx, maxy - i, black) %Top falling box
        drawfillbox (0, 0, maxx, 0 + i, black) %Bottom rising box
        View.Update
    end for
        
    Music.PlayFileStop
end openExit

%Draw Procedure
procedure draw
    %Draw projectile
    if reloadCount < RELOAD_CAP and reloadCount not= 0 and ballCollision = false then
        drawfilloval (round ((oldPlayerX) + reloadCount * projectileModifierX), round ((oldPlayerY) + reloadCount * projectileModifierY), 10, 10, red)
    end if
    
    %Change player sprite position
    Sprite.SetPosition (spriteShadowMage, playerX, playerY, true)
    
    %Show enemies
    for a : 1 .. upper (monsterX)
        if monsterHealth (a) > 0 then
            Sprite.Show (arraySprites (a))
        else
            Sprite.Hide (arraySprites (a))
        end if
    end for
        
    %Draw health, mana, score and round
    Draw.ThickLine (maxx - 200, maxy - 1, maxx - 3, maxy - 1, 3, black) %Top black border line
    Draw.ThickLine (maxx - 200, maxy, maxx - 200, 3, 3, black) %Left black border line
    Draw.ThickLine (maxx - 200, 2, maxx - 3, 2, 3, black) %Bottom black border line
    Draw.ThickLine (maxx - 2, maxy, maxx - 2, 3, 3, black) %Right black border line
    drawfillbox (maxx - 198, 4, maxx - 4, maxy - 3, white)
    Font.Draw ("Health: " + intstr (health), maxx - 150, 400, font, red)
    Font.Draw ("Mana: " + intstr (mana), maxx - 150, 350, font, blue)
    Font.Draw ("Score: " + intstr (score * 5), maxx - 150, 300, font, green)
    Font.Draw ("Round " + intstr (difficulty div 1 - 3), maxx - 150, 500, fontHeader, green)
    View.Update
end draw

%Procedure for initialize game at start
procedure initialize
    cls
    
    %Player X and Y and regen count
    playerX := maxx div 2 - 100
    playerY := maxy div 2
    
    manaRegenCount := 0
    
    %Variables for firing projectiles
    projectileModifierX := 0
    projectileModifierY := 0
    oldPlayerX := 0
    oldPlayerY := 0
    reloadCount := 0
    ballCollision := false
    
    %Variables for firing special projectile
    special := false
    specialModifierX := 0
    specialModifierY := 0
    oldSpecialPlayerX := 0
    oldSpecialPlayerY := 0
    specialReloadCount := 0
    specialCollision := true
    explosion := false
    explosionCount := 0
    
    %Variables for knockback spell
    r := 0
    knockback := false
    
    %Variables for heal
    heal := false
    healRadiusMod := 0
    
    
    %Player Health, mana, score, enemies killed, difficulty,
        health := 100
    mana := 100
    score := 0
    enemyKilled := 0
    difficulty := 4
    Sprite.Show (spriteShadowMage)
    
    %Enemy health + special + location + enemy sprites are initialized
    for b : 1 .. 4
        monsterHealth (b) := MONSTER_HEALTH
        monsterSpecial (b) := false
    end for
        
    monsterX (1) := 0
    monsterX (2) := maxx
    monsterX (3) := 0
    monsterX (4) := maxx
    
    monsterY (1) := 0
    monsterY (2) := 0
    monsterY (3) := maxy
    monsterY (4) := maxy
    
    arraySprites (1) := Sprite.New (picSnake)
    arraySprites (2) := Sprite.New (picSnake)
    arraySprites (3) := Sprite.New (picSnake)
    arraySprites (4) := Sprite.New (picSnake)
end initialize



%Pull up initial menu
openMenu
Music.PlayFileLoop ("Realm of the Mad God Soundtrack - Title BGM.mp3")

%Outer loop (Menus)
loop
    %Checks mouse coordinates and whether the mouse is clicked
    Mouse.Where (mouseX, mouseY, mouseStat)
    
    %Click cooldown (not in-game)
    if playButton = false then
        %Once mouse button is lifted up and the count is 2 or above, reset count
        if mouseStat = 0 and clickCooldown > 2 then
            clickCooldown := 0
        end if
        
        %When mouse is held down, loop will run once with the mouse being down, and then changes mouseStat to up any other runthroughs
        if mouseStat = 1 then
            clickCooldown := clickCooldown + 1
            if clickCooldown > 2 then
                mouseStat := 0
            end if
        end if
    end if
    
    %Checks parameters when on main menu
    if menuButton = true then
        %When in Instructions button, clicking will open Instructions
        if mouseX >= 120 and mouseX <= 539 and mouseY <= 479 and mouseY >= 390 and mouseStat = 1 then
            openInstructions
            
            %When in About button, clicking will open About
        elsif mouseX >= 930 and mouseX <= 1139 and mouseY <= 469 and mouseY >= 400 and mouseStat = 1 then
            openAbout
            
            %When in Exit button, clicking will open Exit
        elsif mouseX >= 120 and mouseX <= 259 and mouseY <= 139 and mouseY >= 80 and mouseStat = 1 then
            openExit
            exit
            
            %When in Play button, clicking will begin game
        elsif mouseX >= 450 and mouseX <= 789 and mouseY <= 320 and mouseY >= 220 and mouseStat = 1 then
            
            %Initializes game values (go to initialize procedure)
            initialize
            
            %Game loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            loop
                
                %Leave game loop and go to Scores when health is lower than 1
                if health < 1 then
                    openScores
                    exit
                end if
                
                %New monster creation
                previousMonsterUpper := upper (monsterX)
                new monsterX, (difficulty div 1)
                new monsterY, (difficulty div 1)
                new monsterHealth, (difficulty div 1)
                new monsterSpecial, (difficulty div 1)
                new arraySprites, (difficulty div 1)
                %If new monster created, set values for it
                if upper (monsterX) > previousMonsterUpper then
                    %Monster will spawn in one of the corners
                    monsterX (upper (monsterX)) := (Rand.Int (0, 1)) * (maxx - 300) + 25
                    monsterY (upper (monsterX)) := (Rand.Int (0, 1)) * (maxy - 100) + 25
                    %Monster has full health
                    monsterHealth (upper (monsterX)) := MONSTER_HEALTH
                    %Chance of night ninja spawning is higher over time
                    if Rand.Int (1, upper (monsterX)) > upper (monsterX) / 2 + 2 then
                        monsterSpecial (upper (monsterX)) := true
                        arraySprites (upper (monsterX)) := Sprite.New (picNinja)
                    else
                        monsterSpecial (upper (monsterX)) := false
                        arraySprites (upper (monsterX)) := Sprite.New (picSnake)
                    end if
                    %Revive dead enemies every time a new one is created
                    for count : 1 .. upper (monsterX)
                        if monsterHealth (count) <= 0 then
                            monsterX (count) := Rand.Int (0, 1) * (maxx - 275) + 25
                            monsterY (count) := Rand.Int (0, 1) * (maxy - 50) + 25
                            monsterHealth (count) := MONSTER_HEALTH
                        end if
                    end for
                end if
                
                %Monster Movement
                for c : 1 .. upper (monsterX)
                    %if monster is alive
                    if monsterHealth (c) > 0 then
                        %Get monster distance
                        monsterDistance := sqrt ((playerX - monsterX (c)) ** 2 + (playerY - (monsterY (c))) ** 2)
                        %if monster is normal, make it travel at a normal speed
                        if monsterSpecial (c) = false then
                            monsterTravelTime := monsterDistance / MONSTER_SPEED
                            %Used to avoid division by 0
                            if monsterTravelTime = 0 then
                                monsterTravelTime := 1
                            end if
                            %Use algebra and slope to calculate enemy movement
                            monsterModifierX := (playerX - (monsterX (c))) / monsterTravelTime
                            monsterModifierY := (playerY - (monsterY (c))) / monsterTravelTime
                            monsterX (c) := round (monsterX (c) + monsterModifierX * MONSTER_SPEED)
                            monsterY (c) := round (monsterY (c) + monsterModifierY * MONSTER_SPEED)
                        end if
                        %If enemy is special, make it travel fast
                        if monsterSpecial (c) = true then
                            monsterTravelTime := monsterDistance / MONSTER_SPECIAL_SPEED
                            %Used to avoid division by 0
                            if monsterTravelTime = 0 then
                                monsterTravelTime := 1
                            end if
                            %Use algebra and slope to calculate enemy movement
                            monsterModifierX := (playerX - (monsterX (c))) / monsterTravelTime
                            monsterModifierY := (playerY - (monsterY (c))) / monsterTravelTime
                            monsterX (c) := round (monsterX (c) + monsterModifierX * MONSTER_SPECIAL_SPEED)
                            monsterY (c) := round (monsterY (c) + monsterModifierY * MONSTER_SPECIAL_SPEED)
                        end if
                        
                        Sprite.SetPosition (arraySprites (c), monsterX (c), monsterY (c), true)
                        %Collision with player and enemy
                        if (monsterX (c) > playerX - 35 and monsterX (c) < playerX + 35) and (monsterY (c) > playerY - 35 and monsterY (c) < playerY + 35) then
                            health := health - monsterHealth (c)
                            monsterHealth (c) := 0
                        end if
                    end if
                end for
                    
                %Collision between enemy and enemy
                for collideA : 1 .. upper (monsterX)
                    for collideB : 1 .. upper (monsterX)
                        %Avoid colliding with dead enemies and itself
                        if (collideA not= collideB) and (monsterHealth (collideA) > 0) and (monsterHealth (collideB) > 0) then
                            %If on top of each other
                            if (monsterX (collideA) = monsterX (collideB)) and (monsterY (collideA) = monsterY (collideB)) then
                                monsterX (collideA) := monsterX (collideA) + 25
                                monsterY (collideA) := monsterY (collideA) + 25
                            end if
                            if abs (monsterX (collideA) - monsterX (collideB)) < 50 and abs (monsterX (collideA) - monsterX (collideB)) < 50 then
                                %X axis collision
                                if abs (playerX - monsterX (collideA)) < abs (playerX - monsterX (collideB)) then
                                    if (playerX - monsterX (collideA)) > 0 then
                                        monsterX (collideA) := monsterX (collideA) + 1
                                    end if
                                    if (playerX - monsterX (collideA)) < 0 then
                                        monsterX (collideA) := monsterX (collideA) - 1
                                    end if
                                end if
                                %Y axis collision
                                if abs (playerY - monsterY (collideA)) < abs (playerY - monsterY (collideB)) then
                                    if (playerY - monsterY (collideA)) > 0 then
                                        monsterY (collideA) := monsterY (collideA) + 1
                                    end if
                                    if (playerY - monsterY (collideA)) < 0 then
                                        monsterY (collideA) := monsterY (collideA) - 1
                                    end if
                                end if
                            end if
                        end if
                    end for
                end for
                    
                %Player Movement
                
                %Use WASD to move, q to activate AOE spell, which is right now not active, space to teleport to cursor, e to knockback enemies, r to heal
                %Get the healPlayer location to make the green circle follow you
                healPlayerX := playerX
                healPlayerY := playerY
                Input.KeyDown (chars)
                locate (1, 1)
                %WASD movement
                if chars ('w') and not (playerY + 25 >= maxy) then
                    playerY := playerY + PLAYER_SPEED
                end if
                if chars ('d') and not (playerX + 25 >= maxx - 201) then
                    playerX := playerX + PLAYER_SPEED
                end if
                if chars ('s') and not (playerY - 25 <= 0) then
                    playerY := playerY - PLAYER_SPEED
                end if
                if chars ('a') and not (playerX - 25 <= 0) then
                    playerX := playerX - PLAYER_SPEED
                end if
                
                %Spells
                %Teleport
                if chars (' ') and mana >= MANA_COST_TELEPORT and teleportCooldown > 50 then
                    %Teleport to mouse coordinates
                    Mouse.Where (targetX, targetY, targetMouseStat)
                    playerX := targetX
                    playerY := targetY
                    mana := mana - MANA_COST_TELEPORT
                    teleportCooldown := 0
                end if
                
                %AOE (Special)
                if chars ('q') and mana >= MANA_COST_SPECIAL and explosion = false and specialReloadCount = 0 then
                    Mouse.Where (specialX, specialY, specialStat)
                    mana := mana - MANA_COST_SPECIAL
                    special := true
                    specialCollision := false
                    specialReloadCount := 0
                    Sprite.Hide (spritePortal)
                end if
                
                %Knockback
                if chars ('e') and mana >= MANA_COST_KNOCKBACK and knockback = false then
                    mana := mana - MANA_COST_KNOCKBACK
                    knockback := true
                    knockbackPlayerX := playerX
                    knockbackPlayerY := playerY
                end if
                
                %Heal
                if chars ('r') and mana >= MANA_COST_HEAL and heal = false then
                    mana := mana - MANA_COST_HEAL
                    heal := true
                    health += HEAL
                end if
                
                %Kills player (sets health to 0 when 'm' is pressed)
                %DEGUGGING ONLY
                if chars ('m') then
                    health := 0
                end if
                
                %Firing projectiles
                %If projectile doesn't already exist
                if reloadCount = 0 then
                    %Get mouse position
                    Mouse.Where (mouseX, mouseY, mouseStat)
                end if
                %If reload count is not above the reload cap. This avoids unlimited bullet lifetime
                if reloadCount < RELOAD_CAP then
                    %If mouse button was pressed
                    if mouseStat = 1 then
                        %If the bullet was just fired
                        if reloadCount = 0 then
                            %Math needed to calculate the trajectory of the bullet, moves based on an increasing reloadCount times a modifier based on travel time and displacement
                            projectileDistance := sqrt ((mouseX - (playerX)) ** 2 + (mouseY - (playerY)) ** 2)
                            projectileTravelTime := projectileDistance / PROJECTILE_SPEED
                            if projectileTravelTime = 0 then
                                projectileTravelTime := 1
                            end if
                            projectileModifierX := (mouseX - (playerX)) / projectileTravelTime
                            projectileModifierY := (mouseY - (playerY)) / projectileTravelTime
                            %Gets the oldPlayerX and Y to stop the bullet from moving when you move
                            oldPlayerX := playerX
                            oldPlayerY := playerY
                        end if
                        View.Update
                        %If ball has not collided yet
                        if ballCollision = false then
                            %Redraw background
                            drawfillbox (0, 0, maxx - 201, maxy, 67)
                        end if
                        %Increase reloadCount by 1 to keep track of bullet lifetime/span
                        reloadCount := reloadCount + 1
                    end if
                else
                    %If the projectile has lived too long, set reloadCount back to one, and ballCollision back to false. Note that the reload count still increases even when collision is true, to ensure even reload times.
                    reloadCount := 0
                    ballCollision := false
                end if
                %Check to see if the ball has collided with an enemy
                for d : 1 .. upper (monsterX)
                    if monsterHealth (d) > 0 then
                        if ballCollision = false then
                            %Range of +/- 20 for both x and y, so a 40 x 40 pixel hit box
                            if round ((oldPlayerX) + reloadCount * projectileModifierX) > monsterX (d) - 20 and round ((oldPlayerX) + reloadCount * projectileModifierX) < monsterX (d)
                                + 20 and round ((oldPlayerY) + reloadCount * projectileModifierY) > monsterY (d) - 20 and round ((oldPlayerY) + reloadCount * projectileModifierY) <
                                monsterY (d) + 20 then
                                %Set collision to true
                                ballCollision := true
                                %Reduce monster health by projectile damage
                                monsterHealth (d) := monsterHealth (d) - PROJECTILE_DAMAGE
                                %If enemy is dead, increase score and enemyKilled count
                                if monsterHealth (d) <= 0 then
                                    if monsterSpecial (d) = false then
                                        score += 1
                                        enemyKilled += 1
                                    else
                                        score += 2
                                        enemyKilled += 1
                                    end if
                                end if
                            end if
                        end if
                    end if
                end for
                    
                
                %Special projectile firing for aoe spell
                %If special projectile has not been too long on screen
                if specialReloadCount < SPECIAL_RELOAD_CAP then
                    %If spell is currently active
                    if special = true then
                        %If spell was just casted
                        if specialReloadCount = 0 then
                            %Algebra used to calculate the movement towards the direction of the mouse, based on distance, time and speed.
                            specialDistance := sqrt ((specialX - (playerX)) ** 2 + (specialY - (playerY)) ** 2)
                            specialTravelTime := specialDistance / SPECIAL_PROJECTILE_SPEED
                            %Avoid division by 0
                            if specialTravelTime = 0 then
                                specialTravelTime := 1
                            end if
                            specialModifierX := (specialX - (playerX)) / specialTravelTime
                            specialModifierY := (specialY - (playerY)) / specialTravelTime
                            oldSpecialPlayerX := playerX
                            oldSpecialPlayerY := playerY
                        end if
                        View.Update
                        %If not collided yet and not outside the boundaries of the map
                        if specialCollision = false and not (round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX) > maxx - 201) then
                            %Move the special projectile and show its sprite
                            Sprite.SetPosition (spriteSpecial, round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX), round ((oldSpecialPlayerY) + specialReloadCount *
                            specialModifierY), true)
                            Sprite.Show (spriteSpecial)
                        else
                            %If not, hide the sprite
                            Sprite.Hide (spriteSpecial)
                        end if
                        %Increase reload count by 1 to keep track of the time since the casting of the spell
                        specialReloadCount := specialReloadCount + 1
                    end if
                    %If the projectile has lasted long enough (specialReloadCount >= SPECIAL_RELOAD_CAP) and has not collided yet
                elsif specialCollision = false then
                    %If not outside the map
                    if not (round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX) > maxx - 201) then
                        %Create the explosion. Explosion is true, set explosionX and Y to current special projectile location, set portal to that location, and show it
                        explosion := true
                        explosionX := round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX)
                        explosionY := round ((oldSpecialPlayerY) + specialReloadCount * specialModifierY)
                        Sprite.SetPosition (spritePortal, explosionX, explosionY, true)
                        Sprite.Show (spritePortal)
                        %Kill all enemies in a +/- 100 pixel hitbox for both x and y
                        for e : 1 .. upper (monsterX)
                            if monsterHealth (e) > 0 then
                                if monsterX (e) > explosionX - 100 and monsterX (e) < explosionX + 100 and monsterY (e) > explosionY - 100 and monsterY (e) < explosionY + 100 then
                                    monsterHealth (e) := 0
                                    %Increase score and enemy killed
                                    if monsterSpecial (e) = false then
                                        score += 1
                                        enemyKilled += 1
                                    else
                                        score += 2
                                        enemyKilled += 1
                                    end if
                                end if
                            end if
                        end for
                    end if
                    %Reset the specialReloadCount to 0, collision to true, and the spell cast to false, and hide the sprite
                    specialReloadCount := 0
                    specialCollision := true
                    special := false
                    Sprite.Hide (spriteSpecial)
                end if
                for d : 1 .. upper (monsterX)
                    if monsterHealth (d) > 0 then
                        if specialCollision = false then
                            %Check to see if the special projectile has collided with an enemy in a +/- 20 pixel hitbox
                            if round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX) > monsterX (d) - 20 and round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX) <
                                monsterX (d)
                                + 20 and round ((oldSpecialPlayerY) + specialReloadCount * specialModifierY) > monsterY (d) - 20 and round ((oldSpecialPlayerY) + specialReloadCount *
                                specialModifierY) <
                                monsterY (d) + 20 then
                                specialCollision := true
                                %Create the explosion. Explosion is true, set explosionX and Y to current special projectile location, set portal to that location, and show it
                                explosion := true
                                explosionX := round ((oldSpecialPlayerX) + specialReloadCount * specialModifierX)
                                explosionY := round ((oldSpecialPlayerY) + specialReloadCount * specialModifierY)
                                Sprite.SetPosition (spritePortal, explosionX, explosionY, true)
                                Sprite.Show (spritePortal)
                                %Kill all enemies in a +/- 100 pixel hitbox for both x and y
                                for e : 1 .. upper (monsterX)
                                    if monsterHealth (e) > 0 then
                                        if monsterX (e) > explosionX - 100 and monsterX (e) < explosionX + 100 and monsterY (e) > explosionY - 100 and monsterY (e) < explosionY + 100 then
                                            monsterHealth (e) := 0
                                            %Increase score and enemy killed
                                            if monsterSpecial (e) = false then
                                                score += 1
                                                enemyKilled += 1
                                            else
                                                score += 2
                                                enemyKilled += 1
                                            end if
                                        end if
                                    end if
                                end for
                            end if
                        end if
                    end if
                end for
                    
                %If the special projectile has collided, hide the sprite
                if specialCollision = true then
                    Sprite.Hide (spriteSpecial)
                end if
                
                %Knockback Spell
                %If spell is cast
                if knockback = true then
                    %If the radius has not exceeded the max
                    if r < RADIUS_MAX then
                        %Draw background
                        drawfillbox (0, 0, maxx - 201, maxy, 67)
                        %Increase radius by 10 to give ripple effect
                        r += 10
                        %Draw the circle to represent the ring expansion
                        drawoval (knockbackPlayerX, knockbackPlayerY, round (r), round (r), blue)
                        for k : 1 .. upper (monsterX)
                            %If enemy is within the knockback circle
                            if (sqrt ((monsterX (k) - knockbackPlayerX) ** 2 + (monsterY (k) - knockbackPlayerY) ** 2) <= r) and ((knockbackPlayerX - monsterX (k)) not= 0) then
                                %Begin Math! Find the equation of the line that passes through the enemy and the player, in y=mx+b form, aka find knockbackLineSlope and knockbackLineYIntercept
                                knockbackLineSlope := (knockbackPlayerY - monsterY (k)) / ((knockbackPlayerX - monsterX (k)))
                                knockbackLineYIntercept := monsterY (k) - knockbackLineSlope * (monsterX (k))
                                %Quadratics! Fun! Since the above line passes through two points on the circle, we have to use quadratics formula: (-B +/- sqrt (B ** 2 - 4 * A * C)) / 2 * A
                                %A, B, and C are derived from the following: substitute the values for the y = mx+b line into the equation of a circle, expand, simplify and rearrange the numbers until you get something in the form Ax**2 + Bx + C
                                knockbackQuadraticsA := knockbackLineSlope ** 2 + 1
                                knockbackQuadraticsB := 2 * (knockbackLineSlope * knockbackLineYIntercept - knockbackLineSlope * knockbackPlayerY - knockbackPlayerX)
                                knockbackQuadraticsC := knockbackPlayerY ** 2 - r ** 2 + knockbackPlayerX ** 2 - 2 * knockbackLineYIntercept * knockbackPlayerY + knockbackLineYIntercept ** 2
                                %Since quadratics uses +/-, determine which one to use. - for if the monster is to the left of the player (enemy has lower X)
                                if monsterX (k) < knockbackPlayerX and monsterX (k) > knockbackPlayerX - r then
                                    monsterX (k) := round ((-knockbackQuadraticsB - sqrt (knockbackQuadraticsB ** 2 - 4 * knockbackQuadraticsA * knockbackQuadraticsC)) / (2 * knockbackQuadraticsA))
                                    monsterY (k) := round (knockbackLineSlope * monsterX (k) + knockbackLineYIntercept)
                                    %+ for if the monster is to the right of the player (enemy has higher X)
                                elsif monsterX (k) >= knockbackPlayerX and monsterX (k) < knockbackPlayerX + r then
                                    monsterX (k) := round ((-knockbackQuadraticsB + sqrt (knockbackQuadraticsB ** 2 - 4 * knockbackQuadraticsA * knockbackQuadraticsC)) / (2 * knockbackQuadraticsA))
                                    monsterY (k) := round (knockbackLineSlope * monsterX (k) + knockbackLineYIntercept)
                                end if
                            end if
                            %If there is no X displacement, but the Y is still in range. This is neccessary because the above quadratics only works if the difference of X values of player and enemy is not 0
                            if ((knockbackPlayerX - monsterX (k))) = 0 and abs (knockbackPlayerY - monsterY (k)) <= r then
                                %If enemy is lower in Y, push it down
                                if monsterY (k) < knockbackPlayerY then
                                    monsterY (k) := round (knockbackPlayerY - r)
                                    %If it is higher in Y, push it up
                                elsif monsterY (k) >= knockbackPlayerY then
                                    monsterY (k) := round (knockbackPlayerY + r)
                                end if
                            end if
                        end for
                        else
                        %Draw background
                        drawfillbox (0, 0, maxx - 201, maxy, 67)
                        %Reset r to 0 and say spell is not cast
                        r := 0
                        knockback := false
                    end if
                end if
                
                %Mana Regen
                if mana < 100 and manaRegenCount mod 10 = 0 then
                    mana := mana + 1
                end if
                
                %Spell Cooldown
                if teleportCooldown <= 100 then
                    teleportCooldown := teleportCooldown + 1
                end if
                
                %Explosion Drawings
                if explosion = true then
                    %Increase explosionCount by 1 to determine how long the portal has been on screen for
                        explosionCount := explosionCount + 1
                    for e : 1 .. upper (monsterX)
                        if monsterHealth (e) > 0 then
                            %Kill all enemies within a +/- 100 hitbox of the portal center
                            if monsterX (e) > explosionX - 100 and monsterX (e) < explosionX + 100 and monsterY (e) > explosionY - 100 and monsterY (e) < explosionY + 100 then
                                monsterHealth (e) := 0
                                if monsterSpecial (e) = false then
                                    score += 1
                                    enemyKilled += 1
                                else
                                    score += 2
                                    enemyKilled += 1
                                end if
                            end if
                        end if
                    end for
                    elsif explosionCount not= 0 then
                    %If explosion is not true and the explosion count is not 0, reset it to 0
                    explosionCount := 0
                end if
                
                %If the explosion has been too long on the screen
                if explosionCount >= EXPLOSION_COUNT_MAX then
                    %Hide the portal, set reload count to 0, set explosion spell and special projectile to false (not active)
                    Sprite.Hide (spritePortal)
                    specialReloadCount := 0
                    explosion := false
                    special := false
                end if
                
                %Heal
                if heal = true then
                    %Draw a small green circle that increases around the enemy to represent healing, reaching a maximum radius of 50
                    if healRadiusMod < 50 then
                        drawfillbox (0, 0, maxx - 201, maxy, 67)
                        healRadiusMod += 2
                        drawoval (playerX, playerY, healRadiusMod, healRadiusMod, green)
                    else
                        %When it reaches 50, reset the radius and set heal to inactive
                        drawfillbox (0, 0, maxx - 201, maxy, 67)
                        healRadiusMod := 0
                        heal := false
                    end if
                end if
                
                %Don't let health go over 100
                if health > 100 then
                    health := 100
                %Don't let health go below 0
                elsif health < 0 then
                    health := 0
                end if
                
                %Update visuals
                draw
                View.Update
                %Delay, affects gameplay speed
                delay (15)
                %Increase difficulty
                difficulty := difficulty + DIFFICULTY_RATE
                %Increase manaRegenCount by 1
                manaRegenCount := manaRegenCount + 2
                
                %Movement boundaries
                if playerX - 25 <= 0 then
                    playerX := 25
                elsif playerX + 25 >= maxx - 201 then
                    playerX := maxx - 226
                end if
                if playerY - 25 <= 0 then
                    playerY := 25
                elsif playerY + 25 >= maxy then
                    playerY := maxy - 25
                end if
                
                for bound : 1 .. upper (monsterX)
                    if monsterX (bound) - 25 <= 0 then
                        monsterX (bound) := 25
                    elsif monsterX (bound) + 25 >= maxx - 201 then
                        monsterX (bound) := maxx - 226
                    end if
                    if monsterY (bound) - 25 <= 0 then
                        monsterY (bound) := 25
                    elsif monsterY (bound) + 25 >= maxy then
                        monsterY (bound) := maxy - 25
                    end if
                end for
                    
            end loop
            
        end if
        
        
        %Checks parameters when on instructions menu
    elsif instructionsButton = true then
        %Back to main menu
        if mouseX >= 1020 and mouseX <= 1199 and mouseY <= 149 and mouseY >= 60 and mouseStat = 1 then
            openMenu
            
            %Shows Rules sprite following mouse when hovering over the tab
        elsif mouseX >= 130 and mouseX <= 329 and mouseY <= 359 and mouseY >= 260 then
            %Brings mouseY below the mouse if the box exceeds height
            if mouseY + 325 >= maxy then
                mouseY := mouseY - 325
            end if
            %Sets and shows Rules sprite
            Sprite.SetPosition (spriteRules, mouseX, mouseY, false)
            Sprite.Show (spriteRules)
            
            %Shows Controls sprite following mouse when hovering over the tab
        elsif mouseX >= 500 and mouseX <= 829 and mouseY <= 359 and mouseY >= 260 then
            %Brings mouseY to the left of mouse if the box exceeds maxy
            if mouseX + 550 >= maxx then
                mouseX := mouseX - 550
            end if
            %Brings mouseY below the mouse if the box exceeds height
            if mouseY + 325 >= maxy then
                mouseY := mouseY - 325
            end if
            %Sets and shows Controls sprite
            Sprite.SetPosition (spriteControls, mouseX, mouseY, false)
            Sprite.Show (spriteControls)
            
            %Shows Tips sprite following mouse when hovering over the tab
        elsif mouseX >= 1000 and mouseX <= 1159 and mouseY <= 359 and mouseY >= 260 then
            %Sets and shows Tips sprite
            Sprite.SetPosition (spriteTips, mouseX - 575, mouseY, false)
            Sprite.Show (spriteTips)
            
            %If not hovering over one of the tabs, then hide all the sprites
        else
            Sprite.Hide (spriteRules)
            Sprite.Hide (spriteControls)
            Sprite.Hide (spriteTips)
        end if
        
        %Checks parameters when on about menu
    elsif aboutButton = true then
        %Back to main menu
        if mouseX >= 1020 and mouseX <= 1199 and mouseY <= 149 and mouseY >= 60 and mouseStat = 1 then
            openMenu
        end if
        
    end if
end loop
