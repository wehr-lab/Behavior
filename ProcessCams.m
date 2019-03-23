function ProcessCams(varargin)
	choice = varargin; %'eyes' and/or 'ears'
	datadir=pwd; %default to pwd
	cd(datadir)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sky
        Find.vid = dir('Sky_mouse*.avi'); %raw video from bonsai
            if length(Find.vid) < 1
                Find.vid = dir('Sky_mouse*.mkv'); %or h265 compressed video through FFmpeg
            end
            if length(Find.vid) < 1
                Find.vid = dir('Sky_mouse*.mp4'); %or h264 compressed video through FFmpeg
            end
            if length(Find.vid) > 1
                for i = 1:length(Find.vid)
                    if length(Find.vid(i).name) == 38
                        Sky.vid = Find.vid(i); %choose raw
                    end
                end
            end
        Find.csv = dir('Sky_mouse*.csv'); %timestamps & triggervalues from bonsai
            if length(Find.csv) > 1
                for i = 1:length(Find.csv)
                    if length(Find.csv(i).name) == 38
                        Sky.csv = Find.csv(i); %choose raw
                    end
                end
            end
            Sky.bonsai = textscan(fopen(Sky.csv.name),'%q');
            Sky.bonsai = Sky.bonsai{1,1}; %Timestamp and triggervalue

            Sky.times = cell2mat(Sky.bonsai(1:2:end,:)); %SkyVid timestamps
            Sky.times = Sky.times(:,1:27);
            Sky.length = length(Sky.times);
            for i=1:Sky.length
                Sky.times(i,:) = strrep(Sky.times(i,:),'T','_');
            end
            Sky.times = datetime(Sky.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');

            Sky.trigval = Sky.bonsai(2:2:end,:); %trigger values
            Sky.trigs = find(~cellfun(@isempty,strfind(Sky.trigval,'True'))); %Framenumber for all triggered SkyCam frames
            for i=1:length(Sky.trigs)
                if i>1
                    Sky.temp(i)=Sky.trigs(i)-Sky.trigs(i-1); %subtract previous trigger framenumber.
                else
                    Sky.temp(i)=90;
                end
            end
            Sky.temp2 = Sky.temp - ones(size(Sky.temp));
            Sky.temp3 = find(Sky.temp2);
            Sky.TTs = Sky.trigs(Sky.temp3(1,:),1);
            Sky.TTslength = length(Sky.TTs);
            Sky = rmfield(Sky,'temp');
            Sky = rmfield(Sky,'temp2');
            Sky = rmfield(Sky,'temp3');
            % Safety measures. Should include a rigorous method for
            % trigger# checks in the future
            Sky.TTtimes = Sky.times(Sky.TTs,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sky Track
        SkyTrack.vid = dir('Sky_mouseDeep*.mp4');
            temp = dir('temp-Sky_mouse*');
        SkyTrack.images = strcat(pwd,'\',temp.name);
            temp = Sky.vid.name;
            temp = strsplit(temp,'.');
            temp = temp{1};
            temp = strcat(temp,'DeepCut*.csv');
        SkyTrack.csv = dir(temp);
            SkyTrack.raw = textscan(fopen(SkyTrack.csv.name),'%q');
            SkyTrack.raw = SkyTrack.raw{1};
            [SkyTrack] = readDLCOutput(SkyTrack);

            mo = Video_Player;
            waitfor(mo)
            load('stopframe.mat');
            delete('stopframe.mat');
            SkyTrack.skystop = stopframe;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EYEs
    [proceed] = IsAny(choice,'eyes');
    if proceed == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Left Eye
        Leye.vid = dir('Leye_mouse*Deinterlaced.avi');
            if length(Leye.vid) < 1
                Leye.vid = dir('Leye_mouse*Deinterlaced.mkv'); %or h265 compressed video through FFmpeg
            end
            if length(Leye.vid) < 1
                Leye.vid = dir('Leye_mouse*Deinterlaced.mp4'); %or h264 compressed video through FFmpeg
            end
        Find.csv = dir('Leye_mouse*.csv'); %timestamps from bonsai
            if length(Find.csv) > 1
                for i = 1:length(Find.csv)
                    if length(Find.csv(i).name) == 39
                        Leye.csv = Find.csv(i); %choose raw
                    end
                end
            end
            Leye.bonsai = textscan(fopen(Leye.csv.name),'%q');
            Leye.bonsai = cell2mat(Leye.bonsai{1,1});
            Leye.times = Leye.bonsai(:,1:27);
            Leye.length = length(Leye.times);
            for i=1:Leye.length
                Leye.times(i,:) = strrep(Leye.times(i,:),'T','_');
            end
            Leye.times = datetime(Leye.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
            for i=1:Sky.TTslength
                Leye.TTs(i) = find(Sky.TTtimes(i)<Leye.times, 1); %framenumber of triggered EyeCam
            end
            Leye.TTtimes = Leye.times(Leye.TTs);
            Leye.Tdur = time(between(Leye.times(1),Leye.TTtimes,'time'));
            Leye.dur = time(between(Leye.times(1),Leye.times,'time'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Left Eye Track
        LeyeTrack.vid = dir('Leye_mouseDeep*.mp4');
            if length(LeyeTrack.vid) > 1
                for i = 1:length(LeyeTrack.vid)
                    testlength{i} = length(LeyeTrack.vid(i).name);
                end
                LeyeTrack.vid = LeyeTrack.vid(find(max(testlength{:}))); %choose DI tracked
            end
            temp = dir('temp-Leye_mouse*Deinterlaced');
        LeyeTrack.images = strcat(pwd,'\',temp.name);
            temp = Leye.vid.name;
            temp = strsplit(temp,'.');
            temp = temp{1};
            temp = strcat(temp,'DeepCut*.csv');
        LeyeTrack.csv = dir(temp);
            LeyeTrack.raw = textscan(fopen(LeyeTrack.csv.name),'%q');
            LeyeTrack.raw = LeyeTrack.raw{1};
            [LeyeTrack] = readDLCOutput(LeyeTrack);
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Right Eye
        Reye.vid = dir('Reye_mouse*Deinterlaced.avi');
            if length(Reye.vid) < 1
                Reye.vid = dir('Reye_mouse*Deinterlaced.mkv'); %or h265 compressed video through FFmpeg
            end
            if length(Reye.vid) < 1
                Reye.vid = dir('Reye_mouse*Deinterlaced.mp4'); %or h264 compressed video through FFmpeg
            end
            
        Find.csv = dir('Reye_mouse*.csv'); %timestamps from bonsai
            if length(Find.csv) > 1
                for i = 1:length(Find.csv)
                    if length(Find.csv(i).name) == 39
                        Reye.csv = Find.csv(i); %choose raw
                    end
                end
            end
            Reye.bonsai = textscan(fopen(Reye.csv.name),'%q');
            Reye.bonsai = cell2mat(Reye.bonsai{1,1});
            Reye.times = Reye.bonsai(:,1:27);
            Reye.length = length(Reye.times);
            for i=1:Reye.length
                Reye.times(i,:) = strrep(Reye.times(i,:),'T','_');
            end
            Reye.times = datetime(Reye.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
            for i=1:Sky.TTslength
                Reye.TTs(i) = find(Sky.TTtimes(i)<Reye.times, 1); %framenumber of triggered EyeCam
            end
            Reye.TTtimes = Reye.times(Reye.TTs);
            Reye.Tdur = time(between(Reye.times(1),Reye.TTtimes,'time'));
            Reye.dur = time(between(Reye.times(1),Reye.times,'time'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Right Eye Track
        ReyeTrack.vid = dir('Reye_mouseDeep*.mp4');
            if length(ReyeTrack.vid) > 1
                for i = 1:length(ReyeTrack.vid)
                    testlength{i} = length(ReyeTrack.vid(i).name);
                end
                ReyeTrack.vid = ReyeTrack.vid(find(max(testlength{:}))); %choose DI tracked
            end
            temp = dir('temp-Reye_mouse*Deinterlaced');
        ReyeTrack.images = strcat(pwd,'\',temp.name);
            temp = Reye.vid.name;
            temp = strsplit(temp,'.');
            temp = temp{1};
            temp = strcat(temp,'DeepCut*.csv');
        ReyeTrack.csv = dir(temp);
            ReyeTrack.raw = textscan(fopen(ReyeTrack.csv.name),'%q');
            ReyeTrack.raw = ReyeTrack.raw{1};
            [ReyeTrack] = readDLCOutput(ReyeTrack);
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EARs
    [proceed] = IsAny(choice,'ears');
    if proceed == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Right Ear
        Rear.vid = dir('Rear_mouse*Deinterlaced.avi');
            if length(Rear.vid) < 1
                Rear.vid = dir('Rear_mouse*Deinterlaced.mkv'); %or h265 compressed video through FFmpeg
            end
            if length(Rear.vid) < 1
                Rear.vid = dir('Rear_mouse*Deinterlaced.mp4'); %or h264 compressed video through FFmpeg
            end
            
        Find.csv = dir('Rear_mouse*.csv'); %timestamps from bonsai
            if length(Find.csv) > 1
                for i = 1:length(Find.csv)
                    if length(Find.csv(i).name) == 39
                        Rear.csv = Find.csv(i); %choose raw
                    end
                end
            end
            Rear.bonsai = textscan(fopen(Rear.csv.name),'%q');
            Rear.bonsai = cell2mat(Rear.bonsai{1,1});
            Rear.times = Rear.bonsai(:,1:27);
            Rear.length = length(Rear.times);
            for i=1:Rear.length
                Rear.times(i,:) = strrep(Rear.times(i,:),'T','_');
            end
            Rear.times = datetime(Rear.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
            for i=1:Sky.TTslength
                Rear.TTs(i) = find(Sky.TTtimes(i)<Rear.times, 1); %framenumber of triggered EarCam
            end
            Rear.TTtimes = Rear.times(Rear.TTs);
            Rear.Tdur = time(between(Rear.times(1),Rear.TTtimes,'time'));
            Rear.dur = time(between(Rear.times(1),Rear.times,'time'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Right Ear Track
        RearTrack.vid = dir('Rear_mouseDeep*.mp4');
            if length(RearTrack.vid) > 1
                for i = 1:length(RearTrack.vid)
                    testlength{i} = length(RearTrack.vid(i).name);
                end
                RearTrack.vid = RearTrack.vid(find(max(testlength{:}))); %choose DI tracked
            end
            temp = dir('temp-Rear_mouse*Deinterlaced');
        RearTrack.images = strcat(pwd,'\',temp.name);
            temp = Rear.vid.name;
            temp = strsplit(temp,'.');
            temp = temp{1};
            temp = strcat(temp,'DeepCut*.csv');
        RearTrack.csv = dir(temp);
            RearTrack.raw = textscan(fopen(RearTrack.csv.name),'%q');
            RearTrack.raw = RearTrack.raw{1};
            [RearTrack] = readDLCOutput(RearTrack);
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Left Ear
        Lear.vid = dir('Lear_mouse*Deinterlaced.avi');
            if length(Lear.vid) < 1
                Lear.vid = dir('Lear_mouse*Deinterlaced.mkv'); %or h265 compressed video through FFmpeg
            end
            if length(Lear.vid) < 1
                Lear.vid = dir('Lear_mouse*Deinterlaced.mp4'); %or h264 compressed video through FFmpeg
            end
            
        Find.csv = dir('Lear_mouse*.csv'); %timestamps from bonsai
            if length(Find.csv) > 1
                for i = 1:length(Find.csv)
                    if length(Find.csv(i).name) == 39
                        Lear.csv = Find.csv(i); %choose raw
                    end
                end
            end
            Lear.bonsai = textscan(fopen(Lear.csv.name),'%q');
            Lear.bonsai = cell2mat(Lear.bonsai{1,1});
            Lear.times = Lear.bonsai(:,1:27);
            Lear.length = length(Lear.times);
            for i=1:Lear.length
                Lear.times(i,:) = strrep(Lear.times(i,:),'T','_');
            end
            Lear.times = datetime(Lear.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
            for i=1:Sky.TTslength
                Lear.TTs(i) = find(Sky.TTtimes(i)<Lear.times, 1); %framenumber of triggered EarCam
            end
            Lear.TTtimes = Lear.times(Lear.TTs);
            Lear.Tdur = time(between(Lear.times(1),Lear.TTtimes,'time'));
            Lear.dur = time(between(Lear.times(1),Lear.times,'time'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Left Ear Track
        LearTrack.vid = dir('Lear_mouseDeep*.mp4');
            if length(LearTrack.vid) > 1
                for i = 1:length(LearTrack.vid)
                    testlength{i} = length(LearTrack.vid(i).name);
                end
                LearTrack.vid = LearTrack.vid(find(max(testlength{:}))); %choose DI tracked
            end
            temp = dir('temp-Lear_mouse*Deinterlaced');
        LearTrack.images = strcat(pwd,'\',temp.name);
            temp = Lear.vid.name;
            temp = strsplit(temp,'.');
            temp = temp{1};
            temp = strcat(temp,'DeepCut*.csv');
        LearTrack.csv = dir(temp);
            LearTrack.raw = textscan(fopen(LearTrack.csv.name),'%q');
            LearTrack.raw = LearTrack.raw{1};
            [LearTrack] = readDLCOutput(LearTrack);
            
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save
    clear temp;
    clear i;
    clear datadir;
    clear Find;
    clear varargin;
    clear testlength;
    clear stopframe;
    clear choice;
    clear proceed;
    Behavior = strcat('Behavior', Sky.vid.name(4:34));
    save (Behavior)
end


%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Spy cam
%         Spy.vid = dir('Spy_mouse*Deinterlaced.avi'); %raw video from bonsai
%             if length(Spy.vid) < 1
%                 Spy.vid = dir('Spy_mouse*Deinterlaced.mkv'); %or compressed video through FFmpeg
%             end
%             if length(Spy.vid) < 1 
%                 Spy.vid = dir('Spy_mouse*Deinterlaced.mp4'); %or compressed video through FFmpeg
%             end
%             
%         Find.csv = dir('Spy_mouse*.csv'); %timestamps from bonsai
%             if length(Find.csv) > 1 
%                 for i = 1:length(Find.csv)
%                     if length(Find.csv(i).name) == 38
%                         Spy.csv = Find.csv(i); %choose raw
%                     else
%                     end
%                 end
%             end
%             Spy.bonsai = textscan(fopen(Spy.csv.name),'%q');
%             Spy.bonsai = cell2mat(Spy.bonsai{1,1});
%             Spy.times = Spy.bonsai(:,1:27);
%             Spy.length = length(Spy.times);
%             for i=1:Spy.length
%                 Spy.times(i,:) = strrep(Spy.times(i,:),'T','_');
%             end
%             Spy.times = datetime(Spy.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
%             for i=1:Sky.TTslength
%                 Spy.TTs(i) = find(Sky.TTtimes(i)<Spy.times, 1); %framenumber of triggered EarCam
%             end
%             Spy.TTtimes = Spy.times(Spy.TTs);
%             Spy.Tdur = time(between(Spy.times(1),Spy.TTtimes,'time'));
%             Spy.dur = time(between(Spy.times(1),Spy.times,'time'));
