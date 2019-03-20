%accelerometer channels are 33, 34, 35 in OpenEphys, but are stored as 32,
%33, and 34
node='';
NodeIds=getNodes(pwd);
for i=1:length(NodeIds)
    filename=sprintf('%s_AUX1.continuous', NodeIds{i});
    if exist(filename,'file')
        node=NodeIds{i};
    end
end
filename1=sprintf('%s_AUX1.continuous', node); %(-) = Forward
filename2=sprintf('%s_AUX2.continuous', node); %(-) = Up
filename3=sprintf('%s_AUX3.continuous', node); %(-) = Left

if exist(filename1, 'file')~=2 %couldn't find it
    error(sprintf('could not find AUX file %s in datadir %s', filename1, datadir))
end
if exist(filename2, 'file')~=2 %couldn't find it
    error(sprintf('could not find AUX file %s in datadir %s', filename2, datadir))
end
if exist(filename3, 'file')~=2 %couldn't find it
    error(sprintf('could not find AUX file %s in datadir %s', filename3, datadir))
end
fprintf('\n')
[scaledtrace1, datatimestamps, datainfo] =load_open_ephys_data(filename1);
[scaledtrace2, datatimestamps, datainfo] =load_open_ephys_data(filename2);
[scaledtrace3, datatimestamps, datainfo] =load_open_ephys_data(filename3);

%combine X,Y,Z accelerometer channels by RMS
%scaledtrace=sqrt(scaledtrace1.^2 + scaledtrace2.^2 + scaledtrace3.^2 );
%scaledtrace=sqrt(scaledtrace3.^2 + scaledtrace2.^2);
scaledtrace=sqrt(scaledtrace1.^2);

SCTfname=getSCTfile(pwd);
stimfile=getStimfile(pwd); %mw 08.30.2107 old: sprintf('%s_ADC2.continuous', node);

laserfile=getLaserfile(pwd); %mw 08.30.2107 old: sprintf('%s_ADC2.continuous', node);

[stim, stimtimestamps, stiminfo] =load_open_ephys_data(stimfile);
[lasertrace, lasertimestamps, laserinfo] =load_open_ephys_data(laserfile);
% [scttrace, scttimestamps, sctinfo] =load_open_ephys_data(SCTfname);

%uncomment this to run some sanity checks
%SCT_Monitor(datadir, StartAcquisitionSec, Events, all_channels_data, all_channels_timestamps, all_channels_info)

samprate=sampleRate;

%%%%%%%%%%%%%%
%get freqs/amps
j=0;
for i=1:length(Events)
    if strcmp(Events(i).type, 'clicktrain')
        j=j+1;
        allicis(i)=Events(i).ici;
        alldurs(i)=Events(i).duration;
        %       if isfield(Events(i), 'nclicks')
        allnclicks(i)=Events(i).nclicks;
        allamps(i)=Events(i).amplitude;
        allclickdurations(i)=Events(i).clickduration;
    end
end
%%%%%%%%%%%%%%
icis=unique(allicis);
nclicks=unique(allnclicks);
nclicks=sort(nclicks, 'descend');
durs=unique(alldurs);
amps=unique(allamps);
numicis=length(icis);
numnclicks=length(nclicks);
numamps=length(amps);
numdurs=length(durs);
nrepsON=zeros(numicis, 1);
nrepsOFF=zeros(numicis, 1);

%check for laser in Events
for i=1:length(Events)
    if isfield(Events(i), 'laser') & isfield(Events(i), 'LaserOnOff')
        if isempty(Events(i).laser)
            Events(i).laser=0;
        end
        LaserScheduled(i)=Events(i).laser; %whether the stim protocol scheduled a laser for this stim
        LaserOnOffButton(i)=Events(i).LaserOnOff; %whether the laser button was turned on
        LaserTrials(i)=LaserScheduled(i) & LaserOnOffButton(i);
        if isempty(stimlog(i).LaserStart)
            LaserStart(i)=nan;
            LaserWidth(i)=nan;
            LaserNumPulses(i)=nan;
            LaserISI(i)=nan;
        else
            LaserStart(i)=stimlog(i).LaserStart;
            LaserWidth(i)=stimlog(i).LaserWidth;
            LaserNumPulses(i)=stimlog(i).LaserNumPulses;
            LaserISI(i)=stimlog(i).LaserISI;
        end
        
    elseif isfield(Events(i), 'laser') & ~isfield(Events(i), 'LaserOnOff')
        %Not sure about this one. Assume no laser for now, but investigate.
        warning('ProcessGPIAS_PSTH_single: Cannot tell if laser button was turned on in djmaus GUI');
        LaserTrials(i)=0;
        Events(i).laser=0;
    elseif ~isfield(Events(i), 'laser') & ~isfield(Events(i), 'LaserOnOff')
        %if neither of the right fields are there, assume no laser
        LaserTrials(i)=0;
        Events(i).laser=0;
    elseif ~isfield(Events(i), 'laser') & isfield(Events(i), 'LaserOnOff')
        %if laser field is not there, assume no laser
        LaserTrials(i)=0;
        Events(i).laser=0;
    else
        error('wtf?')
    end
end
fprintf('\n%d laser pulses in this Events file', sum(LaserTrials))
try
    if sum(LaserOnOffButton)==0
        fprintf('\nLaser On/Off button remained off for entire file.')
    end
end
if sum(LaserTrials)>0
    IL=1;
else
    IL=0;
end
%if lasers were used, we'll un-interleave them and save ON and OFF data
%try to load laser and stimulus monitor files
if isempty(getLaserfile('.'))
    LaserRecorded=0;
else
    LaserRecorded=1;
end
if isempty(getStimfile('.'))
    StimRecorded=0;
else
    StimRecorded=1;
end

if LaserRecorded
    try
        [Lasertrace, Lasertimestamps, Laserinfo] =load_open_ephys_data(getLaserfile('.'));
        Lasertimestamps=Lasertimestamps-StartAcquisitionSec; %zero timestamps to start of acquisition
        Lasertrace=Lasertrace./max(abs(Lasertrace));
        fprintf('\nsuccessfully loaded laser trace\n')
    catch
        fprintf('\nfound laser file %s but could not load laser trace', getLaserfile('.'))
    end
else
    fprintf('\nLaser trace not recorded')
end
if StimRecorded
    try
        [Stimtrace, Stimtimestamps, Stiminfo] =load_open_ephys_data(getStimfile('.'));
        Stimtimestamps=Stimtimestamps-StartAcquisitionSec; %zero timestamps to start of acquisition
        Stimtrace=Stimtrace./max(abs(Stimtrace));
        fprintf('\nsuccessfully loaded stim trace')
    catch
        fprintf('\nfound stim file %s but could not load stim trace', getStimfile('.'))
    end
else
    fprintf('\nSound stimulus trace not recorded')
end