%% Info:
% Once a set of sessions has been kilosorted and tracked with DLC, define 
% the two inputs below and run this script in one of the bonsai experiment
% folders to process them all together:

%% Inputs:
LocalDataRoot = 'E:\NickNick\'; %your local path to where all the experiment folders are
Rig = 'Rig2old'; %string indicating the rig these experiments were run on

%% Load the paths of the experiment folders:
load('Bdirs.mat'); %This file contains the paths to all the experiment folders that were kilosorted together

%% Process the spikes:
MasterDir = replace(dirs{1},DataRoot,LocalDataRoot); %The path to the master ephys folder
for idx = 1:length(Bdirs) %For each bonsai folder

    [SortedUnits,sampleRate] = ProcessSpikes(idx,MasterDir); %Process the spikes
    CurrentDir = replace(dirs{idx},DataRoot,LocalDataRoot); %path to Ephys folder
    BdirName = erase(Bdirs{idx},{DataRoot}); %name of Bonsai folder
    dirName = erase(CurrentDir,{LocalDataRoot,BdirName,'\','/'}); %name of Ephys folder
    for unit = 1:length(SortedUnits)
        SortedUnits(unit).dir_indx = idx;
        SortedUnits(unit).Bdir = BdirName;
        SortedUnits(unit).dir = dirName;
        SortedUnits(unit).ProcessSpikesDataRoot = LocalDataRoot; %DataRoot of where ProcessSpikes was just ran
        SortedUnits(unit).KilosortedDataRoot = DataRoot; %DataRoot of where kilosort was ran
    end
    savename = strcat('SortedUnits_',BdirName,'.mat');
    save(fullfile(CurrentDir,savename), 'SortedUnits', 'sampleRate'); %Saves SortedUnits & sampleRate as 'SortedUnits.mat' in the ephys folder

end

%% Process the cameras:
for idx = 1:length(Bdirs) %For each bonsai folder

    cd(replace(Bdirs{idx},DataRoot,LocalDataRoot)) %Go to the bonsai folder

    [BehaviorFile] = ProcessCams(Rig); %And run ProcessCams.

    if isequal(Rig,'Rig2old')
        load(BehaviorFile); %Now load the behaviorfile
        [Reye] = ProcessPupil(Reye,0.8); %Calculate the pupil diameter
        save(BehaviorFile, 'Head', 'Reye', 'Sky'); %And save the info back into the behaviorfile
    end
    
end


% Pre-processing Workflow:
% 1) DLC tracking:
%   You can use v_files4DLC('Reye') in matlab to select many videos to input
%   into a python terminal for DLC tracking.
% 
% 2) Kilosort:
%   Run master_16TT in matlab in the first bonsai directory, and then choose 
%   all the trial folders a mouse did that day. Once kilosort has completed,
%   then load up the data in Phy to sort and save the spikes.