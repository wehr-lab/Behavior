function [v_string,v_files] = v_files4DLC(varargin) %Generates a string of specified videos for input into DLC from folders of your choosing
%%%%%   varargin1 = the camera files you want to select ex)'Sky', 'Leye', or 'Reye'
%%%%%   varargin2 = (optional) a predetermined list of folders that you want to generate a v_string from, to input into DLC

choice = varargin{1};
if nargin == 2
    SelectedFolders = varargin{2};
else
    SelectedFolders = uigetfile_n_dir(pwd);
    SelectedFolders = SelectedFolders';
end
k = 0;

%% %%%%%%%%%%%%%%%% Find specific videos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isequal(choice,'Sky')
    for i = 1:length(SelectedFolders)
        SkyFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Sky_m*.mp4'));
        for ii = 1:length(SkyFiles{i,1})
            if length(SkyFiles{i,1}(ii).name) == 38
                if ii > 1
                    k = k + 1;
                    v_list{i+k,1} = strcat(SkyFiles{i,1}(ii).folder,'\',SkyFiles{i,1}(ii).name);
                else
                    v_list{i+k,1} = strcat(SkyFiles{i,1}(ii).folder,'\',SkyFiles{i,1}(ii).name);
                end
            end
        end
    end
elseif isequal(choice,'Leye')
    for i = 1:length(SelectedFolders)
        LeyeFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Leye_m*.mp4'));
        for ii = 1:length(LeyeFiles{i,1})
            if length(LeyeFiles{i,1}(ii).name) == 39
                v_list{i,1} = strcat(LeyeFiles{i,1}(ii).folder,'\',LeyeFiles{i,1}(ii).name);
            end
        end
    end
elseif isequal(choice,'Reye')
    for i = 1:length(SelectedFolders)
        ReyeFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Reye_m*.mp4'));
        for ii = 1:length(ReyeFiles{i,1})
            if length(ReyeFiles{i,1}(ii).name) == 39
                v_list{i,1} = strcat(ReyeFiles{i,1}(ii).folder,'\',ReyeFiles{i,1}(ii).name);
            end
        end
    end
elseif isequal(choice,'Lear')
    for i = 1:length(SelectedFolders)
        LearFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Lear_m*.mp4'));
        for ii = 1:length(LearFiles{i,1})
            if length(LearFiles{i,1}(ii).name) == 39
                v_list{i,1} = strcat(LearFiles{i,1}(ii).folder,'\',LearFiles{i,1}(ii).name);
            end
        end
    end
elseif isequal(choice,'Rear')
    for i = 1:length(SelectedFolders)
        RearFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Rear_m*.mp4'));
        for ii = 1:length(RearFiles{i,1})
            if length(RearFiles{i,1}(ii).name) == 39
                v_list{i,1} = strcat(RearFiles{i,1}(ii).folder,'\',RearFiles{i,1}(ii).name);
            end
        end
    end
elseif isequal(choice,'Eye')
    for i = 1:length(SelectedFolders)
        EyeFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Eye_m*.mkv'));
        for ii = 1:length(EyeFiles{i,1})
            if length(EyeFiles{i,1}(ii).name) == 38
                v_list{i,1} = strcat(EyeFiles{i,1}(ii).folder,'\',EyeFiles{i,1}(ii).name);
            end
        end
    end
elseif isequal(choice,'Head')
    for i = 1:length(SelectedFolders)
        HeadFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Head_m*.mp4'));
        for ii = 1:length(HeadFiles{i,1})
            if length(HeadFiles{i,1}(ii).name) == 39
                v_list{i,1} = strcat(HeadFiles{i,1}(ii).folder,'\',HeadFiles{i,1}(ii).name);
            end
        end
    end
elseif isequal(choice,'Forw')
    for i = 1:length(SelectedFolders)
        ForwFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Forw_m*.mp4'));
        for ii = 1:length(ForwFiles{i,1})
            if length(ForwFiles{i,1}(ii).name) == 39
                v_list{i,1} = strcat(ForwFiles{i,1}(ii).folder,'\',ForwFiles{i,1}(ii).name);
            end
        end
    end
end

%% %%%%%%%%%%%%%%%% reformat '\' to '\\' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(v_list) %for all videos inputted,
    v_files{i,1} = strrep(v_list{i},'\','\\');
end

%% %%%%%%%%%%%%%%%% Generate a  string of all v_files in a python-friendly string %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[v_string] = v_files2string(v_files);
end

%%%%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [v_string] = v_files2string(v_files) %Returns string of all v_files, to feed into python.

v_string = [];
for i = 1:length(v_files)
    if i == 1
        v_string = string(v_files{i});
    else
        v_string = [v_string,'","',string(v_files{i})];
    end
end
end