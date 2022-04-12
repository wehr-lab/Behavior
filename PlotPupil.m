%Example function plotting spiketimes, pupildiameter and SCT:

function PlotPupil(BonsaiDir,EphysDir)
%% 1) load the data files for the trial:

BehaviorFileStr = strcat(BonsaiDir, filesep, 'Beh*.mat');
BehaviorFile = strcat(BonsaiDir,filesep,dir(BehaviorFileStr).name);
load(BehaviorFile);

SortedUnitsFileStr = strcat(EphysDir,filesep,'Sort*.mat');
SortedUnitsFile = strcat(EphysDir,filesep,dir(SortedUnitsFileStr).name);
load(SortedUnitsFile);
notebookfile = fullfile(EphysDir,'notebook.mat');
load(notebookfile);
numcells=length(SortedUnits);

Eventsfile = fullfile(EphysDir,'Events.mat');
load(Eventsfile);
StartAcquisitionSecfile = fullfile(EphysDir,'StartAcquisitionSec.mat');
load(StartAcquisitionSecfile);


%% 2) Get the spiketimes and pupil diameters for each stimulus:
xlimits = [-500,500]; %time window in ms for extracting spikes, relative to stim onset, e.g. -200 to 200
for idx=1:length(Events)
    if strcmp(Events(idx).type, 'tone') || strcmp(Events(idx).type, 'whitenoise') || strcmp(Events(idx).type, 'silentsound')
        if isfield(Events(idx), 'soundcard_trigger_timestamp_sec')
            pos = Events(idx).soundcard_trigger_timestamp_sec*sampleRate();
        else
            error('stimulus delivery timestamp missing')
        end

        %get stimulus params from Events(idx)
        data(idx).stimtype = stimlog(idx).type;
        data(idx).stimparam = stimlog(idx).param;
        data(idx).stimulus_description = stimlog(idx).stimulus_description;

        %get start and stop samples for OpenEphys:
        data(idx).OEstart = (pos+xlimits(1)*(1/1000)*sampleRate); %in samples
        data(idx).OEstop = (pos+xlimits(2)*(1/1000)*sampleRate); %in samples

        %get start and stop frames for Reye camera:
        data(idx).ReyeStart = Reye.TTs(idx)+xlimits(1)*(1/1000)*Reye.vid.framerate; %frame number for start
        data(idx).ReyeStop = Reye.TTs(idx)+xlimits(2)*(1/1000)*Reye.vid.framerate; %frame number for stop

        %get spiketimes for each cell between start &stop
        for cellnumber = 1:length(SortedUnits)
            st = SortedUnits(cellnumber).spiketimes*sampleRate; %spikestimes in sample number
            firstIdx = find(st > data(idx).OEstart,1,'first');
            lastIdx = find(st < data(idx).OEstop,1,'last');
            %spikestimes in sample number, offset by OEstart, and centered in the window:
            data(idx).spiketimes{cellnumber} = st(firstIdx:lastIdx)-data(idx).OEstart+xlimits(1)*(1/1000)*sampleRate;
        end

        %Get pupil diameter values within this range:
        data(idx).PD = (Reye.PupilDiameter(data(idx).ReyeStart:data(idx).ReyeStop));

        %store xlimits time window
        data(idx).xlimits_ms=xlimits;
        data(idx).xlimits_frames=xlimits*(1/1000)*Reye.vid.framerate;
    end
end

%% 3) example plotting of all cells and stimuli

figure
hold on

%Align pupil (in frames of Reye camera clock) to openephys (OE) recording clock
ReyeFirst = Reye.TTs(1); %anchor at first and last stimuli
ReyeLast = Reye.TTs(end);
OEfirst = Events(1).soundcard_trigger_timestamp_sec;
OElast = Events(end).soundcard_trigger_timestamp_sec;
m=(OElast-OEfirst)/(ReyeLast-ReyeFirst);
b=OEfirst - m*ReyeFirst;
numPupilFrames=length(Reye.PupilDiameter);
f=1:numPupilFrames;
tp(f)=m*f + b; %tp is the (interpolated) time in seconds on OE recording clock of each Reye camera frame

plot(tp, Reye.PupilDiameter, 'b', 'linewid', 2)

yl=ylim;
offset=yl(2);
for i=1:numcells
    [firingrate, t]=hist(SortedUnits(i).spiketimes, 0:1:seconds(Sky.dur)); %bin firing rates in 1 second bins
    plot(t, firingrate+offset) %t is in seconds in the openephys reference frame
    offset=offset+20;
end
ylabel('pupil diam (pixels) and firing rate (Hz)')

%% 4) Example plotting of a specific stimulus and cellnumber
stimtype='tone';
freq=2000;
cellnumber = 1;
% This function overlays pupil traces and spike rasters for all repetitions
% of a given stimulus, aligned to stimulus onset
PlotPupilSingle(data,stimtype,freq, cellnumber,sampleRate);


end

    function PlotPupilSingle(data,stimtype,freq, cellnumber,sampleRate)
    indices = [];
    for idx = 1:length(data)
        if isequal(data(idx).stimtype,stimtype) & isequal(data(idx).stimparam.frequency,freq) %find the stims matching the request
            indices = [indices,idx];
        end
    end

    Colors = cool(120);
    figure;
    subplot(2,1,1); title([stimtype, ', ', int2str(freq), 'Hz, color:mean pupil diam']); hold on;
    plot([30,30],[0,120],'k--');
    for idx=indices
        ColorValue(idx) = round(mean(data(idx).PD(:)));
        if isnan(ColorValue(idx))
            ColorValue(idx) = 1;
        end
        PupilDiameter = plot(data(idx).PD(:),'-','Color',Colors(ColorValue(idx),:),'DisplayName','PupilDiameter','MarkerSize',5);
    end
    %ylim([0,120]); 
    xlim([0, diff(data(1).xlimits_frames)]);
    xticks([0,diff(data(1).xlimits_frames)/2,diff(data(1).xlimits_frames)]);
    xticklabels({data(1).xlimits_ms(1),0,data(1).xlimits_ms(2)});
    ylabel('Pupil Diameter (pixels)');
    xlabel('time, ms')

    k = 1;
    subplot(2,1,2); hold on
    plot([0,0],[0,length(indices)],'k--')
    for idx=indices
        ydata = ones(size(data(idx).spiketimes{cellnumber}))*k;
        spikes{k} = plot((data(idx).spiketimes{cellnumber}/sampleRate),ydata,'.','Color',Colors(ColorValue(idx),:));
        k = k+1;
    end
    xticks([data(1).xlimits_ms(1),0,data(1).xlimits_ms(2)]/1000);
    xticklabels({data(1).xlimits_ms(1),0,data(1).xlimits_ms(2)});
    titlestring = strcat('Cell ID #',num2str(cellnumber));
    title(titlestring);
    ylabel('Stimulus repitition'); grid on;
        xlabel('time, ms')

    end


