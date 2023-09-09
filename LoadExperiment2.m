function [nb,stimlog,messages,sampleRate,Events,StartAcquisitionSec] = LoadExperiment2(Sky)
%usage: [nb,stimlog,messages,sampleRate,Events,StartAcquisitionSec] = LoadExperiment2(Sky)
%Sky is the structure in the behavior file saved by ProcessCams (or
%ProcessCamsSocial)
%modified from LoadExperiment to work with new OE file formats and file hierarchy with version 0.6 and open-ephys-matlab-tools
% -mike 9.2023

%I'm passing in the Sky structure because it has all the relevant directory paths
try
    cd(Sky.DataRoot)
    cd(Sky.BonsaiPath)
    cd(Sky.EphysPath)
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

% [messages] = GetNetworkEvents('messages.events');
%
% [all_channels_data, all_channels_timestamps, all_channels_info] = load_open_ephys_data_faster('all_channels.events');
% sampleRate = all_channels_info.header.sampleRate; %in Hz

%get Events and soundcard trigger timestamps
try
    load('Events.mat');
    load('StartAcquisitionSec');
catch
    [Events, StartAcquisitionSec] = GetEventsAndSCT_Timestamps2(Sky);
end

messages=Sky.messages;
sampleRate=Sky.OEsamplerate;



%there are some general notes on the format of Events and network messages in help GetEventsAndSCT_Timestamps

%uncomment this to run some sanity checks
% SCT_Monitor(pwd, StartAcquisitionSec, Events, all_channels_data, all_channels_timestamps, all_channels_info)

