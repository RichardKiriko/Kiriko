local tr = aegisub.gettext

script_name = tr"修正"
script_description = tr"修正60帧对帧出现的偏差"
script_author = "Kiriko"
script_version = "1"

function xz(subs)
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
			local line=subs[i]
	        if line.start_time%50 == 0 and line.start_time ~= 0 then
		        line.start_time=line.start_time+10
	        end
	        if line.end_time%50 == 0 then
		        line.end_time=line.end_time+10
	        end
	        subs[i]=line			
        end
    end
end

aegisub.register_macro(script_name, script_description, xz)