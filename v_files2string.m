function [v_string] = v_files2string(v_files)
%Returns string of all v_files, to feed python.

v_string = [];
for i = 1:length(v_files)
    if i == 1
        v_string = string(v_files{i});
    else
        v_string = [v_string,'","',string(v_files{i})];
    end
end
end


% function [outputstructure] = GetV_list(inputstructure,SelectedFolders)
%     for i = 1:length(SelectedFolders)
%         inputstructure{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Sky_m*.mp4'));
%         for ii = 1:length(inputstructure{i,1})
%             if length(inputstructure{i,1}(ii).name) == 38
%                 v_list{i,1} = strcat(inputstructure{i,1}(ii).folder,'\',inputstructure{i,1}(ii).name);
%             end
%         end
%     end
% end