%Example script showing where to load spike waveforms from a sorted unit. Run in a masterdir folder
clear;

%% Get sorted data from masterdir
load rez.mat; 
st = readNPY('spike_times.npy'); % these are actually in samples, not seconds
clu = readNPY('spike_clusters.npy');
sp = loadKSdir(pwd);    
mmf = memmapfile(sp.dat_path, 'Format', {sp.dtype, [sp.n_channels_dat, rez.ops.recLength(end)], 'x'}); %mmf = memmapfile(filename, 'Format', {dataType, [nChInFile, nSamp], 'x'});

%% Load sortedunits and declare a unit
load('SortedUnits.mat')
ChosenCluster = SortedUnits(1).cluster; %choose a cluster (I just hardcoded the first one as an example here)
channel = SortedUnits(1).channel;

%% Load channel map and find the other 3 channels for this tetrode
load chanMap.mat;
TTchannels = find(kcoords==kcoords(channel));
theseST = st(clu==ChosenCluster); % spike times for ChosenCluster
nWFsToLoad = length(theseST); 

%% Declare the waveform window, then load all the waveforms (from across the trials)   %%%%%%%%%%%%%%%%%%%%%%%
wfWin = [-50:50]; % samples around the spike times to load
nWFsamps = length(wfWin);
theseWF = zeros(nWFsToLoad, sp.n_channels_dat, nWFsamps);
for i=1:nWFsToLoad
    tempWF = mmf.Data.x(1:sp.n_channels_dat,theseST(i)+wfWin(1):theseST(i)+wfWin(end));
    theseWF(i,:,:) = tempWF(chanMap,:);
end

%% Declare the number of spikes you want to highpass filter for plotting
nSpikesToPlot = 40; %(Hardcoded to the first 40 spikes for now)
fpass = 300;

for i=1:nSpikesToPlot %for each spike
    k = 0;
    for channumber = [TTchannels(1):TTchannels(end)] %get the waveform for each TTchannel
        k = k+1;
        temp = zeros(length(nWFsamps));
        waveform = theseWF(i,channumber,1:nWFsamps);
        waveform = waveform(1,:);
        waveform = highpass(waveform,fpass,fs); %and highpass filter it (this is what takes the most time BY FAR)
        waveforms(k,:) = waveform;
    end
    TetrodeWaveforms{i} = waveforms;
end

%% plot the spikes
for i=1:nSpikesToPlot %plot the spikes
    subplot(1,4,1); plot(TetrodeWaveforms{i}(1,:),'Color','b','LineWidth',0.5); hold on; title(strcat('Channel',string(TTchannels(1))));
    subplot(1,4,2); plot(TetrodeWaveforms{i}(2,:),'Color','b','LineWidth',0.5); hold on; title(strcat('Channel',string(TTchannels(2))));
    subplot(1,4,3); plot(TetrodeWaveforms{i}(3,:),'Color','b','LineWidth',0.5); hold on; title(strcat('Channel',string(TTchannels(3))));
    subplot(1,4,4); plot(TetrodeWaveforms{i}(4,:),'Color','b','LineWidth',0.5); hold on; title(strcat('Channel',string(TTchannels(4))));
end
titlestring = strcat('Tetrode:',string(kcoords(channel)),'CellNum:',string(SortedUnits(1).cellnum),' ',string(pwd));
annotation('textbox', [0 0.9 1 0.1], 'String', titlestring, 'EdgeColor', 'none', 'HorizontalAlignment', 'center');