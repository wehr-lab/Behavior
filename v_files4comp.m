function [v_files] = v_files4comp(varargin) %varargin = 'Sky','Eyes',and/or'Ears'
%identifies all specified .avi videos to compress in SelectedFolders.(raw and Deinterlaced)

choice = varargin;
SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

v_filesS = [];
[proceed] = IsAny(choice,'Sky');
if proceed == 1
    for i = 1:length(SelectedFolders)
        SkyFiles{i} = dir(fullfile(SelectedFolders{i}, '**', 'Sky_m*.avi'));
    end
    for i = 1:length(SkyFiles)
        for ii = 1:length(SkyFiles{i})
            v_filesS = [v_filesS; {strcat(SkyFiles{i}(ii).folder,'\',SkyFiles{i}(ii).name)}];
        end
    end
end

v_filesLeye = [];
v_filesReye = [];
[proceed] = IsAny(choice,'Eyes');
if proceed == 1
    for i = 1:length(SelectedFolders)
        LeyeFiles{i} = dir(fullfile(SelectedFolders{i}, '**', 'Leye_m*.avi'));
        ReyeFiles{i} = dir(fullfile(SelectedFolders{i}, '**', 'Reye_m*.avi'));
    end
    for i = 1:length(LeyeFiles)
        for ii = 1:length(LeyeFiles{i})
            v_filesLeye = [v_filesLeye; {strcat(LeyeFiles{i}(ii).folder,'\',LeyeFiles{i}(ii).name)}];
        end
    end
    for i = 1:length(ReyeFiles)
        for ii = 1:length(ReyeFiles{i})
            v_filesReye = [v_filesReye; {strcat(ReyeFiles{i}(ii).folder,'\',ReyeFiles{i}(ii).name)}];
        end
    end
end

v_filesLear = [];
v_filesRear = [];
[proceed] = IsAny(choice,'Ears');
if proceed == 1
    for i = 1:length(SelectedFolders)
        LearFiles{i} = dir(fullfile(SelectedFolders{i}, '**', 'Lear_m*.avi'));
        RearFiles{i} = dir(fullfile(SelectedFolders{i}, '**', 'Rear_m*.avi'));
    end
    for i = 1:length(LearFiles)
        for ii = 1:length(LearFiles{i})
            v_filesLear = [v_filesLear; {strcat(LearFiles{i}(ii).folder,'\',LearFiles{i}(ii).name)}];
        end
    end
    for i = 1:length(RearFiles)
        for ii = 1:length(RearFiles{i})
            v_filesRear = [v_filesRear; {strcat(RearFiles{i}(ii).folder,'\',RearFiles{i}(ii).name)}];
        end
    end
end

v_list = [v_filesS;v_filesLeye;v_filesReye;v_filesLear;v_filesRear];
for i = 1:length(v_list)
    v_files{i,1} = strrep(v_list{i},'\','\\');
end
[v_files] = CellArray2StringArray(v_files);
end