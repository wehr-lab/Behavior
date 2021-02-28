% Processing Workflow:
% 1) DLC tracking:
%   Use v_files4DLC('Sky') in matlab to select many videos to input into a
%   python terminal for DLC tracking.
% 
% 2) Kilosort:
%   Run master_8TT in matlab in first directory, and then choose all the trial
%   folders a mouse did that day. Then sort and save the spikes using Phy.
% 
% The process of kilosorting will make a Bdirs.mat file in every directory, 
% which contains the paths to all the directories that were just batch-processed
% together here. This is useful to load and batch-run the following
% processes in each bonsai directory:

%% ProcessCams: saves a behavior file 'Behavior_mouse-ID##_YYYY-MM-DDTHH_MM_SS',
% which contains relevant information for all the cameras used.

load('Bdirs.mat')
for i = 1:length(Bdirs)
%     cd(Bdirs{i})
%     ProcessCams()
end

%% ProcessSpikes: saves spiketimes for all kilosorted cells labeled 'good' 
% in a cell array: 'st.mat'.

for i = 1:length(Bdirs)
    bdir=Bdirs{i};
    if ismac bdir=macifypath(bdir);end
    cd(bdir)
    behaviorfile = dir('Beh*.mat'); load(behaviorfile.name); %load the behavior file
    ephysfolder=Sky.ephysfolder;
    if ismac ephysfolder=macifypath(ephysfolder);end
    cd(ephysfolder) %cd to the OE folder for this trial
    [SortedUnits,sampleRate] = ProcessSpikes(); %SortedUnits.spiketimes = spiketimes for this trial, in seconds after the start of acquisition for this trial
    save('SortedUnits','SortedUnits','sampleRate'); %saved as 'SortedUnits.mat' in the OE folder
end

%% Assimilate Signals: Makes a file with alignment information for all your data-streams
% from either the first-to-last trigger (default), or a custom range
% inputted into the function.

for i = 1:length(Bdirs)
    bdir=Bdirs{i};
    if ismac bdir=macifypath(bdir);end
    cd(bdir)
    [vids,units,chans] = AssimilateSignals(); %makes Assimilation file
    save('Assimilation','vids','units','chans');
end