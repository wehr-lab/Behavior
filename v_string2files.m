function [v_files] = v_string2files(v_string)
v_files = [];
for i = 1:length(v_string)
    if strlength(v_string(i))>5
        v_files = [v_files,v_string(i)];
    end
end
v_files = v_files';
end