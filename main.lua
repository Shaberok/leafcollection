-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

SCALE_CORRECTOR = 1.5
YES = true
NO = false


system.activate("multitouch")
physics =  require("physics")
--physics.setDrawMode( "hybrid" )

local big_group = display.newGroup()
big_group.x, big_group.y = 0,0


koeff =  math.max(display.contentWidth/1680,display.contentHeight/1050)


function create_bg()

local img = display.newImage("bg.jpg", YES)
big_group:insert(img, YES)
img.x = display.contentWidth/2
img.y = display.contentHeight/2
local koeff =  math.max(display.contentWidth/img.width,display.contentHeight/img.height)
koeffW = display.contentWidth/img.width
koeffH =  display.contentHeight/img.height
img.xScale = koeff
img.yScale = koeff

end
create_bg()

physics.start()
physics.setGravity(0,-0.3*koeff^SCALE_CORRECTOR)

function create_ring(i,x,y,slow)


if not slow then slow = 1 end

local img = display.newImage("bg2.jpg", YES)
koeff2 =  math.max(display.contentWidth/img.width,display.contentHeight/img.height)
local img_group = display.newGroup()
img_group.x, img_group.y = 0,0
img_group:insert(img, YES)
big_group:insert(img_group, YES)


img.xScale = koeff2*((10 + 5/i)/10)
img.yScale = koeff2*((10 + 5/i)/10)


img.xReference = (x - display.contentWidth/2)/koeff2  --+ img_group.x
img.yReference = (y - display.contentHeight/2)/koeff2  --+ img_group.y
img.x = x 
img.y = y 


local mask = graphics.newMask("mask.jpg")
img_group:setMask(mask)

img_group.maskScaleX = 0.1
img_group.maskScaleY = 0.1
img_group.maskX = x -- img.x 
img_group.maskY = y -- img.y


timer.performWithDelay( 3000/i/1.5*slow,function() 

	transition.to( img, {time = 3000/i/3*slow, alpha = 0})
end)
transition.to( img, {time = 3000/i*slow, xScale = koeff2, yScale = koeff2})
transition.to( img_group, {time = 3000/i*slow, maskScaleX = 3/i*koeff2, maskScaleY = 3/i*koeff2, onComplete = 
	function()
		
		img_group:removeSelf()
		
	end})

end




--create_bg()


local delay = 500
local i = 1


local lasttimex = 0
local lasttimey = 0
local timetobulk = os.clock()+0.1

Runtime:addEventListener( "touch", function(event) 
	if event.phase == "ended" then
		create_ring(4,event.x,event.y) 
		pull(event.x,event.y,5)
	elseif event.phase == "began"  then
		push(event.x,event.y,10)
		create_ring(3,event.x,event.y) 
	--elseif timetobulk < os.clock() then
	elseif event.phase == "moved" and ((lasttimex-event.x)^2 + (lasttimey-event.y)^2)^0.5 > display.contentWidth/12.5 and timetobulk < os.clock() then
		lasttimex = event.x
		lasttimey = event.y
		timetobulk = os.clock()+0.03
		create_ring(5,event.x,event.y) 
		pull(event.x,event.y,1)
	end
	--create_ring(2,event.x,event.y) 
end )	

leafs = {}
leafs_img_group = display.newGroup()
leafs_img_group.x, leafs_img_group.y = 0,0
leafs_img_group:toFront()


function new_leaf(img_file, color, scale , x, y, rotation)
if img_file then
	print("new ingfile = "..img_file)
end

if not x then x = display.contentWidth/4 + math.random(display.contentWidth/2) end
if not y then y = display.contentHeight*1.5 end

if not color then color = {255,255,255} end
if not img_file then img_file = "leaf"..math.random(22)..".png" end
if not scale then scale = 0.1 + math.random(3)/10 end
if not rotation then rotation = math.random(360) end

local leaf = display.newImage(img_file, YES)
leafs_img_group:insert(leaf, YES)
leaf.rotation = rotation
leaf.xScale = scale * display.contentWidth/leaf.width * 0.5
leaf.yScale = scale * display.contentWidth/leaf.width * 0.5
leaf:setFillColor(color[1],color[2],color[3])
leaf.scale = scale
leaf.img_file = img_file
table.insert(leafs,leaf)

local num = math.random(628)/100
--leaf.x, leaf.y = display.contentWidth/3 + math.random(display.contentWidth/3), display.contentHeight*1.5
leaf.x, leaf.y = x,y

if not switchedtocollection then
	leaf.body = physics.addBody( leaf, { density=0.1, friction=1, bounce=0.5, radius=leaf.width*leaf.xScale/3 } )
	--leaf:applyForce( 0,  -koeff*SCALE_CORRECTOR*leaf.width*leaf.xScale/15, leaf.x-5+math.random(10),leaf.y-5+math.random(10) 		)
end
--physics.addBody( leaf, { density=0.1, friction=1, bounce=0.5 } )

--
leaf.nexttimebulk = os.clock() + 0.1 + math.random(200)/1000
leaf.update = function()

	if leaf.nexttimebulk<os.clock() then
	
		leaf.nexttimebulk = os.clock() + 1.0 --+ math.random(3000)/1000
		create_ring(5,leaf.x,leaf.y,5)
	end


	
	if
--	leaf.x - display.contentWidth*0.5 > math.abs( display.contentWidth*0.75) or
	leaf.y < - display.contentHeight*0.3 then
			table.remove(leafs,table.indexOf(leafs,leaf))
			print("remove")
			leaf:removeSelf()
			--new_leaf()
	end

end


leaf.touchx = 0
leaf.touchy = 0
leaf.touchboolean = NO
leaf.touchtime = 0


leaf:addEventListener( "touch", function(event) 

	if event.phase == "ended" then
		if leaf.touchboolean then
			if  os.clock() - leaf.touchtime < 0.2 then
				if not switchedtocollection then
					transition.to(leaf, {xScale = 0.5, yScale = 0.5, x = display.contentWidth*0.85, y =  -display.contentHeight*0.25, onComplete = 
					function() 
						if leaf.removeSelf then		
							 x = display.contentWidth*0.5
							 y = display.contentHeight*0.5
							table.insert(collection, {img_file = img_file, color = color, scale = scale, x = x, y = y, rotation = rotation})
							table.remove(leafs,table.indexOf(leafs,leaf))
							print("remove to collection")
							leaf:removeSelf()
						end
						--new_leaf() 
					end})
				else
					transition.to(leaf, {x = 0, y = display.contentWidth*1.25, onComplete = 
					function() 
						if leaf.removeSelf then		
							table.remove(collection, table.indexOf(collection,{img_file = img_file, color = color, scale = scale, x = x, y = y, rotation = rotation}))
							table.remove(leafs,table.indexOf(leafs,leaf))
							print("remove to collection")
							leaf:removeSelf()
						end
						--new_leaf() 
					end})
				end
			end
			
		leaf.touchboolean = NO
		if not switchedtocollection then
			leaf.body = physics.addBody( leaf, { density=0.1, friction=1, bounce=0.5, radius=leaf.width*leaf.xScale/3 } )
		end
		end
	elseif event.phase == "began"  then
		leaf.touchboolean = YES
		leaf.touchx = event.x
		leaf.touchy = event.y
		leaf.touchtime = os.clock()
		if not switchedtocollection then
			physics.removeBody(leaf)
		end
		
	elseif event.phase == "moved" then
		if leaf.touchboolean then
			leaf.x = leaf.x -  (leaf.touchx - event.x)
			leaf.y = leaf.y -  (leaf.touchy - event.y)
			leaf.touchx = event.x
			leaf.touchy = event.y
			--[[
			if switchedtocollection then
				local i = table.indexOf(collection,leaf)
				if i then
					collection[i].x = leaf.x
					collection[i].y = leaf.y
				end
			end
			--]]
		end
	end
	
	return YES
end)


end


function all_leafs_to_collection()
	for i=1, #leafs do
		if leafs[i] then
			table.insert(collection, {img_file = leafs[i].img_file, color = leafs[i].color, scale = leafs[i].scale, x = leafs[i].x, y = leafs[i].y, rotation = leafs[i].rotation})
		else
			print("leaf number "..i.."error. total "..#leafs.." leafs")
		end
	end
end

leafs.update = function()

for i=1, #leafs do
	if leafs[i] then
	leafs[i].update()
	else
	print("leaf number "..i.."error. total "..#leafs.." leafs")
	end
end

end


Runtime:addEventListener("enterFrame", leafs.update)

for i = 1,5 do
--timer.performWithDelay( i*2000,function() 
new_leaf(nil,nil,nil,math.random(display.contentWidth),math.random(display.contentHeight)) 
--end)
end



local dispencer = timer.performWithDelay( 4000,function() new_leaf() end, 0)


function push(x,y,power)



	for i = 1, #leafs do
		local angle = find_angle(leafs[i].x,leafs[i].y,x,y)		
		local forcex=-math.cos(angle)*power*0.2*(koeff^SCALE_CORRECTOR)*leafs[i].width*leafs[i].xScale/5
		local forcey=-math.sin(angle)*power*0.2*(koeff^SCALE_CORRECTOR)*leafs[i].width*leafs[i].xScale/5
		if leafs[i].applyForce then
		leafs[i]:applyForce( forcex, forcey, leafs[i].x,leafs[i].y )
		end
	end
end



function pull(x,y,power)



	for i = 1, #leafs do
		local angle = find_angle(leafs[i].x,leafs[i].y,x,y)		
		local forcex=math.cos(angle)*power*0.05*(koeff^SCALE_CORRECTOR)*leafs[i].width*leafs[i].xScale/5
		local forcey=math.sin(angle)*power*0.05*(koeff^SCALE_CORRECTOR)*leafs[i].width*leafs[i].xScale/5
		if leafs[i].applyForce then
		leafs[i]:applyForce( forcex, forcey, leafs[i].x+display.contentWidth/100,leafs[i].y+display.contentWidth/100 )
		end
	end
end




function find_angle(x1,y1,x2,y2)
	local a=x1-x2;
	local b=y1-y2;
	local angle=0;
	local c=math.sqrt((a^2+b^2));
	local angle=math.asin(a/c)+math.pi*0.5;
	if b>0 then
	angle=-angle;
	end

	return angle;
end


function clean_leafs()
	for i=1,#leafs do
		if leafs[i] then
			if leafs[i].removeself then
				leafs[i]:removeself()
			else
				leafs[i]:removeSelf()
				table.remove(leafs,i)
			end
		end
	end
	
	if #leafs>0 then 
		clean_leafs()
	end
end


collection = {}
--collection_img_group = display.newGroup()

function newCollectionItem(img,scale,rotation,x,y)

	if not img then return end
	if not scale then scale = 1 end
	if not x then x = display.contentWidth/2 end
	if not y then y = display.contentHeight/2 end
	
	local collection_item = {}
	
	collection_item.x = x
	collection_item.y = y
	collection_item.img = img
	collection_item.scale = scale
	collection_item.rotation = rotation
	
end


function switch_to_collection()
	switchedtocollection = YES
	timer.pause(dispencer)
	physics.stop()
	paper = display.newRect(0,0,display.contentWidth*0.9,display.contentHeight*0.9)
	paper.x = display.contentWidth*0.5
	paper.y = display.contentHeight*0.5
	paper:setFillColor(255,240,235)
	clean_leafs()
	leafs_img_group:toFront()
	for i = 1, #collection do
		new_leaf(collection[i].img_file, collection[i].color, collection[i].scale , collection[i].x, collection[i].y, collection[i].rotation)
		print(i)
	end

end


function switch_to_lake()
	switchedtocollection = NO
	
	timer.resume(dispencer)
	physics.start()
	physics.setGravity(0,-0.3*koeff^SCALE_CORRECTOR)
	
	collection = {}
	all_leafs_to_collection()
	clean_leafs()
	
	if paper then
		paper:removeSelf()
		paper = nil
	end

end




koreshek = display.newImage("koreshok.png", YES)


koreshek.xScale,
koreshek.yScale = 
display.contentHeight*0.2/koreshek.height,
display.contentHeight*0.2/koreshek.height

koreshek.x = display.contentWidth*0.9
koreshek.y = display.contentHeight*0.1

koreshek:addEventListener( "touch", function(event) 
	if event.phase == "ended" then
		if not switchedtocollection then
			switch_to_collection()
			koreshek:toFront()
		else
			switchedtocollection = NO
			switch_to_lake()
			
			
			--for i = 1,3 do
			
				new_leaf(nil,nil,nil,math.random(display.contentWidth),math.random(display.contentHeight)) 

			--end
		end
	end

end)















