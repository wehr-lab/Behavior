function [nb,stimlog,messages,sampleRate,Events,StartAcquisitionSec] = LoadExperiment()
%needs to be run from within the openephys data directory

try
    load notebook.mat 
    if ~exist('stimlog','var') %check if stimlog is actually there
        stimlog=[];
        fprintf('\nfound notebook file but there was no stimlog in it!!!');
        fprintf('\n in principle it should be possible to reconstruct all stimuli\nfrom network events, but that would take a lot of coding, does this problem happen often enough to be worth the effort???');
        error('found notebook file but there was no stimlog in it!!!');
    end
    if ~exist('nb','var') %check if nb is actually there
        nb=[];
        warning('found notebook file but there was no nb notebook information in it!!!');
    end
catch
    warning('could not find notebook file')
end

[messages] = GetNetworkEvents('messages.events');

[all_channels_data, all_channels_timestamps, all_channels_info] = load_open_ephys_data_faster('all_channels.events');
sampleRate = all_channels_info.header.sampleRate; %in Hz

%get Events and soundcard trigger timestamps
try
    load('Events.mat');
    load('StartAcquisitionSec');
catch
    [Events, StartAcquisitionSec] = GetEventsAndSCT_Timestamps(messages, sampleRate, all_channels_timestamps, all_channels_data, all_channels_info, stimlog);
    close;
end
%Events.message_timestamp_sec = Events.message_timestamp_sec+StartAcquisitionSec;
%there are some general notes on the format of Events and network messages in help GetEventsAndSCT_Timestamps

%uncomment this to run some sanity checks
% SCT_Monitor(pwd, StartAcquisitionSec, Events, all_channels_data, all_channels_timestamps, all_channels_info)

end