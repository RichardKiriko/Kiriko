local tr = aegisub.gettext
script_name = tr("Add function")
script_description = tr("Add function")
script_author = "kiriko"
script_version = "3.3"



function get_fxs()
	local lines={}
	funs=io.open("funs.lua","a+")
	for line in funs:lines() do
		lines[#lines+1]=line
	end
	funs:close()
	fxs_tbl={}
	for i,line in ipairs(lines) do
		if line == "function_name" then
			fxs_tbl[#fxs_tbl+1]={name=lines[i+1]}
		elseif line == "function_start" then
			start_i=i
		elseif line == "function_end" then
			fxs_tbl[#fxs_tbl].fx=table.concat(lines,"\n",start_i+1,i-1)
		end
	end
return fxs_tbl
end

function file_rewrite()
	funs=io.open("funs.lua","w+")
	for i,fun in ipairs(fxs) do
		funs:write("function_name\n"..fun.name.."\n")
		funs:write("function_start\n"..fun.fx.."\n".."function_end\n")
	end
	funs:close()
end

function refresh()
	fxs={}
	fxs=get_fxs()
	names={}
	for i,fun in ipairs(fxs) do
		table.insert(names,{name=fun.name,i=i})
	end
end

function name_list()
	local list={}
	for k,v in ipairs(names) do
		table.insert(list,"["..v.i.."] "..v.name)
	end
return list
end
	

function add_function(subs)
	refresh()
	repeat
		lable_gui =	{
				{class="label",x=1,y=0,width=1,height=1,label="本插件用于快速添加函数 By Kiriko"},
				{class="label",x=1,y=1,width=1,height=1,label="函数列表："}
			}
		for i,fun in ipairs(fxs) do
			table.insert(lable_gui,{class="checkbox",x=4*math.ceil(i/10)-3,y=(i-1)%10+2,width=3,height=1,label="["..i.."]"..fun.name,name=i,value=false})
		end
		lg,lg_res=aegisub.dialog.display(lable_gui,{"OK","edit","Cancel"})
		if lg == "edit" then
			repeat
			edit_gui = {
					{class="label",x=2,y=0,width=1,height=1,label="函数编辑"},
					{class="dropdown",x=2,y=1,width=1,height=1,name="fx",items=name_list(),value=name_list()[1] or "no fx"}
					}
			eg,eg_res=aegisub.dialog.display(edit_gui,{"complete","edit","add"})
			local fxi=string.match(eg_res.fx,"%[(%d+)%]")*1
			if eg == "add" then
				add_gui = {
						{class="label",x=1,y=0,width=3,height=1,label="function_name"},
						{class="edit",x=4,y=0,width=30,height=1,name="name",value=""},
						{class="label",x=1,y=1,width=1,height=1,label="function"},
						{class="textbox",x=1,y=2,width=60,height=20,name="fx",text=""},
						}
				ag,ag_res=aegisub.dialog.display(add_gui,{"add","cancel"})
				if ag == "add" then
					table.insert(fxs,{name=ag_res.name,fx=ag_res.fx})
				end
			elseif eg == "edit" then
				r_gui = {
						{class="label",x=1,y=0,width=3,height=1,label="function_name"},
						{class="edit",x=4,y=0,width=30,height=1,name="name",value=fxs[fxi].name},
						{class="label",x=1,y=1,width=1,height=1,label="function"},
						{class="textbox",x=1,y=2,width=60,height=20,name="fx",text=fxs[fxi].fx},
						}
				rg,rg_res=aegisub.dialog.display(r_gui,{"complate","delete","cancel"})	
				if rg == "complate" then
					fxs[fxi].name=rg_res.name
					fxs[fxi].fx=rg_res.fx
				elseif rg == "delete" then
					table.remove(fxs,fxi)
				end
			end
			file_rewrite()
			refresh()
			until eg ~= "edit" and eg ~= "add"
		end
	until lg ~= "edit"
	if lg=="Cancel" then 
		aegisub.cancel()
	end	

	for i=1,#subs do
		if subs[i].class == "dialogue" then
			local l=subs[i]
			for k,v in ipairs(fxs) do	
				if lg_res[string.format("%d",k)] then
					l.start_time=0
					l.end_time=0
					local fx_text=string.gsub(v.fx,"%-%-%[[=]*%[.-%][=]*%]%-%-","\n")
					fx_text=string.gsub(fx_text,"%-%-.-\n","\n")
					fx_text=string.gsub(fx_text,"\n"," ")
					l.text=fx_text
					l.effect="code once"
					l.comment = true
					subs.insert(i,l)
				end
			end
		break
		end
	end
end

aegisub.register_macro(script_name, script_description, add_function)
