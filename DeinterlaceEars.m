function [SelectedFolders] = DeinterlaceEars() %Restores signal to 60Hz field rate
%For the model-2 cameras currently
SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

for i = 1:length(SelectedFolders)
    LearFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Lear_m*.avi'));
    for ii = 1:length(LearFiles{i,1})
        if length(LearFiles{i,1}(ii).name) == 39
            v_filesL{i,1} = strcat(LearFiles{i,1}(ii).folder,'\',LearFiles{i,1}(ii).name);
        end
    end
    RearFiles{i,1} = dir(fullfile(SelectedFolders{i}, '**', 'Rear_m*.avi'));
    for ii = 1:length(RearFiles{i,1})
        if length(RearFiles{i,1}(ii).name) == 39
            v_filesR{i,1} = strcat(RearFiles{i,1}(ii).folder,'\',RearFiles{i,1}(ii).name);
        end
    end
end

v_files = [v_filesL;v_filesR];

for i = 1:length(v_files)                       %for all videos found,
    
    showthis = strcat('Working on file:',num2str(i),'of',num2str(length(v_files)));
    disp(showthis)
        
    vid = VideoReader(v_files{i});              %get info
    
    [ImagesFolder] = DeinterlaceFrames(vid);    %Deinterlace each frame
    
    [NewName] = MakeDeinterlacedVideo(vid,ImagesFolder);%Make a video with those frames
    NewNames{i} = NewName;
end

disp('All finished!')
end


%%%%%%%%%%%%%%%%%%%%%%%%    Functions     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ImagesFolder] = DeinterlaceFrames(vid)
    VideoName = strsplit(vid.Name,'.');
    VideoName = VideoName{1};
    cd(vid.path)                                %go to video's directory
    ImagesFolder = strcat('Deinterlace_',VideoName);
    NewName = fullfile(pwd,strcat(VideoName,'Deinterlaced','.avi'));
    NewNameComp = fullfile(pwd,strcat(VideoName,'Deinterlaced','.mp4'));
    if ~exist(NewName) && ~exist(NewNameComp)
        mkdir(ImagesFolder);                    %make a new folder there
        cd(ImagesFolder);                       %go inside folder
        n = vid.NumberOfFrames;
        height = vid.Height;

        %"Filled" version:
        for iframe = 1:n                        %generate deinterlaced frames
            frame = read(vid,iframe);

            a = frame;                  %%%%%     even scan lines     %%%%%
            for iScan = 3:4:height
                a(iScan,:) = a(iScan-1,:);
            end
            for iScan = 4:4:height-1
                a(iScan,:) = a(iScan+1,:);
            end
            filename = strcat('frame',[sprintf('%06d',iframe),'a','.png']);
            fullname = fullfile(pwd,filename);
            imwrite(a,fullname);

            b = frame;                  %%%%%     odd scan lines     %%%%%
            for iScan = 1:4:height
                try
                b(iScan,:) = b(iScan-1,:);
                catch
                b(iScan,:) = b(iScan+1,:);
                end
            end
            for iScan = 2:4:height
                b(iScan,:) = b(iScan+1,:);
            end
            filename = strcat('frame',[sprintf('%06d',iframe),'b','.png']);
            fullname = fullfile(pwd,filename);
            imwrite(b,fullname);
        end
    else
    end
end

function [NewName] = MakeDeinterlacedVideo(vid,ImagesFolder)

    cd(vid.path)                                %go back to vid directory
    VideoName = strsplit(vid.Name,'.');
    VideoName = VideoName{1};
    images = dir(fullfile(ImagesFolder,'*.png'));
    imageNames = {images.name}';                %get names
    imagePaths = {images.folder}';              %and paths for all images
    
    NewName = fullfile(pwd,strcat(VideoName,'Deinterlaced','.avi'));
    NewNameComp = fullfile(pwd,strcat(VideoName,'Deinterlaced','.mp4'));
    if ~exist(NewName) && ~exist(NewNameComp)
        outputVideo = VideoWriter(NewName);
        outputVideo.FrameRate = (vid.FrameRate)*2;
        outputVideo.Quality = 95;
        open(outputVideo)

        for ii = 1:length(imageNames)           %and write new video
           img = imread(fullfile(imagePaths{ii},imageNames{ii}));
           writeVideo(outputVideo,img)
        end

        close(outputVideo)
    else
    end
end


