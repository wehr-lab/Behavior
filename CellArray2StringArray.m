function [newv_files] = CellArray2StringArray(v_files)
newv_files = [];
for i = 1:length(v_files)
    if i ==1
        newv_files = string(v_files{i});
    else
        newv_files = [newv_files,'","',string(v_files{i})];
    end
end
% newv_files = [newv_files, '""'];
end