function [SelectedFolders] = DeinterlaceEyes() %Restores signal to 60Hz field rate
%For the model-1 cameras currently
SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

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

            a = frame;                   %%%%%     odd scan lines     %%%%%
            for iScan = 1:4:height
                try
                a(iScan,:) = a(iScan-1,:);
                catch
                a(iScan,:) = a(iScan+1,:);
                end
            end
            for iScan = 2:4:height
                a(iScan,:) = a(iScan+1,:);
            end
            filename = strcat('frame',[sprintf('%06d',iframe),'a','.png']);
            fullname = fullfile(pwd,filename);
            imwrite(a,fullname);

            b = frame;                  %%%%%     even scan lines     %%%%%
            for iScan = 3:4:height
                b(iScan,:) = b(iScan-1,:);
            end
            for iScan = 4:4:height-1
                b(iScan,:) = b(iScan+1,:);
            end
            filename = strcat('frame',[sprintf('%06d',iframe),'b','.png']);
            fullname = fullfile(pwd,filename);
            imwrite(b,fullname);
        end
    else
    end
    
    %"Blinds" version:
%     for iframe = 1:n
%         frame = read(vid,iframe);
%         
%         a = frame; %%%%%     odd scan lines     %%%%%
%         a(1:4:end,:) = 255;
%         a(2:4:end,:) = 255;
%         filename = strcat('frame',[sprintf('%06d',iframe),'a','.png']);
%         fullname = fullfile(pwd,filename);
%         imwrite(a,fullname);
%         
%         b = frame; %%%%%     even scan lines     %%%%%
%         b(3:4:end,:) = 255;
%         b(4:4:end,:) = 255;
%         filename = strcat('frame',[sprintf('%06d',iframe),'b','.png']);
%         fullname = fullfile(pwd,filename);
%         imwrite(b,fullname);
%     end
end


function [NewName] = MakeDeinterlacedVideo(vid,ImagesFolder)
    
    cd(vid.path)                            %go back to vid directory
    VideoName = strsplit(vid.Name,'.');
    VideoName = VideoName{1};
    images = dir(fullfile(ImagesFolder,'*.png'));
    imageNames = {images.name}';            %get names
    imagePaths = {images.folder}';          %and paths for all images
    
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
