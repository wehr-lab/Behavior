function [v_files] = DeinterlacedV_list(varargin) %varargin = 'Leye','Reye',or'Sky'
%Returns list of deinterlaced videos and deletes deinterlace image folder.
%Do VibrissaeVectors first, so you don't have to regenerate image folder.

choice = varargin{1};
if nargin == 2
    SelectedFolders = varargin{2};
else
    SelectedFolders = uigetfile_n_dir();
    SelectedFolders = SelectedFolders';
end


for i = 1:length(SelectedFolders)
    LeyeFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Leye_m*.mp4'));
    for ii = 1:length(LeyeFiles{i,1})
        if length(LeyeFiles{i,1}(ii).name) == 39
            v_filesL{i,1} = strcat(LeyeFiles{i,1}(ii).folder,'\',LeyeFiles{i,1}(ii).name);
        end
    end
    ReyeFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Reye_m*.mp4'));
    for ii = 1:length(ReyeFiles{i,1})
        if length(ReyeFiles{i,1}(ii).name) == 39
            v_filesR{i,1} = strcat(ReyeFiles{i,1}(ii).folder,'\',ReyeFiles{i,1}(ii).name);
        end
    end
    SkyFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Sky_m*.mp4'));
    for ii = 1:length(SkyFiles{i,1})
        if length(SkyFiles{i,1}(ii).name) == 38
            v_filesS{i,1} = strcat(SkyFiles{i,1}(ii).folder,'\',SkyFiles{i,1}(ii).name);
        end
    end
end

if isequal(choice,'Leye')
    v_list = v_filesL;
elseif isequal(choice,'Reye')
    v_list = v_filesR;
elseif isequal(choice,'Sky')
    v_list = v_filesS;
end
% v_list = [v_filesL;v_filesR];

if or(isequal(choice,'Leye'),isequal(choice,'Reye'))
    for i = 1:length(v_list)                   %for all videos inputted,

        showthis = strcat('Working on file:',num2str(i),'of',num2str(length(v_list)));
        disp(showthis)

        clear NewName
        clear ImagesFolder
        [ImagesFolder,NewName] = GetNewName(v_list{i});

        v_files{i,1} = NewName;

%         DeleteImagesFolder(ImagesFolder,NewName)
    end
elseif isequal(choice,'Sky')
    for i = 1:length(v_list)                   %for all videos inputted,

        showthis = strcat('Working on file:',num2str(i),'of',num2str(length(v_list)));
        disp(showthis)
        
        v_files{i,1} = strrep(v_list{i},'\','\\');
    end
end

disp('All finished!')
end

function [ImagesFolder,NewName] = GetNewName(v_file)
    VideoName = strsplit(v_file,'\');
    vidpath = strcat(VideoName{1},'\\',VideoName{2},'\\',VideoName{3});
    VideoName = VideoName{4};
    VideoName = strsplit(VideoName,'.');
    VideoName = VideoName{1};
    cd(vidpath)
    ImagesFolder = strcat('Deinterlace_',VideoName);
    NewName = strcat(vidpath,strcat('\\',VideoName,'Deinterlaced','.avi'));
end

function DeleteImagesFolder(ImagesFolder,NewName)
    if exist(NewName)
        if exist(ImagesFolder)
            rmdir(ImagesFolder,'s')
        end
    end
end