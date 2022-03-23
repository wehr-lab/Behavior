%Example script plotting spiketimes, pupildiameter, and SCTs:
%run this from within a bonsai data folder

%as written this function plots spikes and pupil diameter and soundcard
%trigs on one plot but they are not aligned in time - so it's very
%misleading

%load data
test = dir('beh*.mat'); load(test.name);
load('AssimilationWO.mat');
notefilename=strcat(Sky.ephysfolder,'\notebook.mat');
load(macifypath(notefilename, 'rig1'));
SortedUnitsfilename=strcat(Sky.ephysfolder,'\SortedUnits.mat');
load(macifypath(SortedUnitsfilename, 'rig1'));

%get spikestimes and PD for the time window forst-to-last trigger
%% Original Plot:
allspiketimes = [];
for cellnumber = 1:length(units)
    st = units(cellnumber).spiketimes;
    firstIdx = find(st > units(cellnumber).start,1,'first');
    lastIdx = find(st < units(cellnumber).stop,1,'last');
    spiketimes{cellnumber} = st(firstIdx:lastIdx);
    allspiketimes = [allspiketimes , spiketimes{cellnumber}];
end
PD = (Reye.PupilDiameter(Reye.TTs(1):Reye.TTs(end)));

%plot pupil
% subplot(2,1,1);
figure
PupilDiameter = plot(PD,'.','DisplayName','PupilDiameter','MarkerSize',5); hold on
grid on;
xticks(0:60*60:length(PD)); xt = xticks;
xticklabels((xt/Reye.vid.framerate)/60);
ylabel('Pupil Diameter (pixels)','FontSize',25); 

% plot soundcard triggers
TTs = Reye.TTs(1:end)-Reye.TTs(1);
yvalues = ones(size(TTs))*110;
SCTs = plot(TTs,yvalues,'k.','DisplayName','SCTs','MarkerSize',5);
legend([SCTs,PupilDiameter],'Location','southeast','AutoUpdate','off')

%plot cell rasters
k = 1;
map = colormap(jet(length(units)));
% subplot(2,1,2);
for cellnumber = 1:length(units)
    yvalues = ones(size(spiketimes{cellnumber}))*k;
    plot(spiketimes{cellnumber}*Reye.vid.framerate,yvalues,'.','Color',map(k,:),'MarkerSize',4); hold on;
%     plot(spiketimes{cellnumber}*Reye.vid.framerate,yvalues,'.','MarkerSize',5); hold on;
    k = k+1;
end
xticks(0:60*60:length(PD)); xt = xticks;
xticklabels((xt/Reye.vid.framerate)/60);
% ylabel('Cell Number','FontSize',25); 
xlabel('Time (min)','FontSize',25)
grid on;

%extract spiketrains and pupil aligned to each sound stimulus
%PSEUDOCODE for now to give the gist
    [Events etc...]=LoadExperiment
xlimits = time window in ms for extracting spikes, relative to stim onset, e.g. -100 to 200
for i=1:length(Events)
    if strcmp(Events(i).type, 'tone') | strcmp(Events(i).type, 'whitenoise') | ...
            strcmp(Events(i).type, 'silentsound')
        if  isfield(Events(i), 'soundcard_trigger_timestamp_sec')
            pos=Events(i).soundcard_trigger_timestamp_sec;
        else
            error('???')
        end
        start=(pos+xlimits(1)*1e-3); %in seconds
        stop=(pos+xlimits(2)*1e-3);
        get stimulus params from Events(i)
        get spiketimes for each cell between start:stop
        convert start, stop to Reye space
        get pupil diameter trace for start to stop
    end
end
