require "Yutils"
local yshape={}

function yshape.text_to_shape(text,style)
    assert(type(text) == "string","text is not a string")
	assert(type(style) == "table","style is not a table")
    texts=Yutils.decode.create_font(style.fontname,style.bold, style.italic, style.underline, style.strikeout,style.fontsize,style.scale_x/100,style.scale_y/100,style.spacing).text_to_shape(text)    
	shape_text=""
	for shape in string.gmatch(texts,"m[^m]+") do
	    local first_point=string.match(shape,"m ([%d%.-]+ [%d%.-]+)")
		local last_point=string.match(shape,"([%d%.-]+ [%d%.-]+) c")
	    if last_point ~= nil then
            shape=string.gsub(shape,"c","l "..first_point)   
		end
		shape_text=shape_text..shape
	end
return shape_text
end

function yshape.text_to_pixels(text,style)
    assert(type(text) == "string","text is not a string")
	assert(type(style) == "table","style is not a table")
	texts=Yutils.decode.create_font(style.fontname,style.bold, style.italic, style.underline, style.strikeout,style.fontsize,style.scale_x/100,style.scale_y/100,style.spacing).text_to_shape(text)
	texts=string.gsub(texts,"c","")
	pixels=Yutils.shape.to_pixels(texts)
return pixels
end

--闪电生成函数用法：Lighting(x1,y1,x2,y2,displace,curDetail,thickness_min,thickness_max)    
--▶x1,y1,x2,y2：图形起始与结束的坐标位置    
--▶displace：最大位移值(数值越大,线条越曲折)    
--▶curDetail:最小切割值(数值越小,则线条数量越多,每条线也越短,也就是线段被切的越碎)    
--▶thickness_min/max:线条粗细(在min与max范围内随机,如果min与max相等，则为固定粗细)
function yshape.lighting(x1,y1,x2,y2,displace,curDetail,thickness_min,thickness_max)
  	pos_table = {}
 	pos_table_temp = {}
 	shape_table = {}
 	shape_table_reverse = {}
  	local function drawLightning(x1,y1,x2,y2,displace)
  		if (displace < curDetail) then
			pos_table[#pos_table+1] = {x1,y1,x2,y2}
 		else 				
			local mid_x = (x1+x2)/2
 			local mid_y = (y1+y2)/2
 			mid_x = mid_x + (math.random(0,1)-0.5) * displace
 			mid_y = mid_y + (math.random(0,1)-0.5) * displace
 			drawLightning(x1,y1,mid_x,mid_y,displace/2)
 			drawLightning(mid_x,mid_y,x2,y2,displace/2)
		end
	end  	
	do 	drawLightning(x1,y1,x2,y2,displace) 	
	end  	
	for var=1,#pos_table do 		
	    shape_table[var] = _G.table.concat(pos_table[var]," ",3,4)  		
	    pos_table_temp[var] = {} 		
	    pos_table_temp[var][3] = pos_table[var][3] 		
	    pos_table_temp[var][4] = pos_table[var][4]+math.random(thickness_min,thickness_max)  		
	    shape_table_reverse[#pos_table-var+1] = _G.table.concat(pos_table_temp[var]," ",3,4)  	
	end
    lighting_shape=string.format("m %d %d l ",x1,y1).._G.table.concat(shape_table," ").." ".._G.table.concat(shape_table_reverse," ")
return lighting_shape 
end

function yshape.bounding_an(ass_shape,mode)
    assert(type(ass_shape) == "string", "ass_shape is not a string")
    assert(type(mode) == "number", "mode is not a number")
	local b=yshape.bounding(ass_shape)
	if mode == 7 then
	    new_shape=Yutils.shape.move(ass_shape,-b.left,-b.top)
	elseif mode == 1 then
	    new_shape=Yutils.shape.move(ass_shape,-b.left,-b.bottom)
	elseif mode == 2 then
	    new_shape=Yutils.shape.move(ass_shape,-b.center,-b.bottom)
	elseif mode == 3 then
	    new_shape=Yutils.shape.move(ass_shape,-b.right,-b.bottom)
	elseif mode == 4 then
	    new_shape=Yutils.shape.move(ass_shape,-b.left,-b.middle)
	elseif mode == 5 then
	    new_shape=Yutils.shape.move(ass_shape,-b.center,-b.middle)
	elseif mode == 6 then
	    new_shape=Yutils.shape.move(ass_shape,-b.right,-b.middle)
	elseif mode == 8 then
	    new_shape=Yutils.shape.move(ass_shape,-b.center,-b.top)
	elseif mode == 9 then
	    new_shape=Yutils.shape.move(ass_shape,-b.right,-b.top)
	end
return new_shape
end

function yshape.bounding(ass_shape)
	assert(type(ass_shape) == "string", "ass_shape is not a string")
	local x1,y1,x2,y2=Yutils.shape.bounding(ass_shape)
	local tbl={left=x1,right=x2,center=(x1+x2)/2,top=y1,bottom=y2,middle=(y1+y2)/2,width=x2-x1,height=y2-y1}
return tbl
end

function yshape.scale(ass_shape,xscale,yscale)
    assert(type(ass_shape) == "string", "ass_shape is not a string")
	if xscale == nil then
		xscale = 1
	else
		xscale = xscale/100
	end
	if yscale == nil then
		yscale = 1
	else
		yscale = yscale/100
	end
return Yutils.shape.filter(ass_shape,function(x,y) return x*xscale,y*yscale end)
end

_G.yshape = yshape
return _G.yshape