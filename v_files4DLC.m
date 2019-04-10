function [v_string,v_files] = v_files4DLC(varargin) %varargin = 'Leye','Reye',or'Sky'
%Returns string of specified videos for input into DLC.

choice = varargin{1};
if nargin == 2
    SelectedFolders = varargin{2};
else
    SelectedFolders = uigetfile_n_dir(pwd);
    SelectedFolders = SelectedFolders';
end

%%%%%%%%%%%%%%%% Find specific videos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isequal(choice,'Sky')
    for i = 1:length(SelectedFolders)
        SkyFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Sky_m*.mp4'));
        for ii = 1:length(SkyFiles{i,1})
            if length(SkyFiles{i,1}(ii).name) == 38
                v_list{i,1} = strcat(SkyFiles{i,1}(ii).folder,'\',SkyFiles{i,1}(ii).name);
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
end


%%%%%%%%%%%%%%%% reformat '\' to '\\' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isequal(choice,'Eye')                    %Deinterlaced videos
    for i = 1:length(v_list) %for all videos inputted,

        showthis = strcat('Working on file:',num2str(i),'of',num2str(length(v_list)));
        disp(showthis)

        v_files{i,1} = strrep(v_list{i},'\','\\');
%         DeleteImagesFolder(ImagesFolder,NewName)
    end
elseif isequal(choice,'Sky')                                        
    for i = 1:length(v_list) %for all videos inputted,

        showthis = strcat('Working on file:',num2str(i),'of',num2str(length(v_list)));
        disp(showthis)
        
        v_files{i,1} = strrep(v_list{i},'\','\\');
    end    
elseif ~isequal(choice,'Sky')                    %Deinterlaced videos
    for i = 1:length(v_list) %for all videos inputted,

        showthis = strcat('Working on file:',num2str(i),'of',num2str(length(v_list)));
        disp(showthis)

        [ImagesFolder,NewName] = GetNewName(v_list{i});

        v_files{i,1} = NewName;
%         DeleteImagesFolder(ImagesFolder,NewName)
    end
end

[v_string] = v_files2string(v_files);
end





function [ImagesFolder,NewName] = GetNewName(v_file)
    VideoName = strsplit(v_file,'\');
    vidpath = strcat(VideoName{1},'\\',VideoName{2},'\\',VideoName{3});
    VideoName = VideoName{4};
    VideoName = strsplit(VideoName,'.');
    VideoName = VideoName{1};
    cd(vidpath)
    ImagesFolder = strcat('Deinterlace_',VideoName);
    NewName = strcat(vidpath,strcat('\\',VideoName,'Deinterlaced','.mp4'));
end

function DeleteImagesFolder(ImagesFolder,NewName)
    if exist(NewName)
        if exist(ImagesFolder)
            rmdir(ImagesFolder,'s')
        end
    end
end