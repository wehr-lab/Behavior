%% Info:
% Once a set of sessions has been kilosorted and tracked with DLC, define
% the two inputs below and run this script in one of the bonsai experiment
% folders to process them all together:

clear

%% Inputs:
% LocalDataRoot = 'E:\NickNick\'; %your local path to where all the experiment folders are
LocalDataRoot =  '/Volumes/wehrlab/Rig2/maddie/'
Rig = 'Rig2old'; %string indicating the rig these experiments were run on


cd(LocalDataRoot)
d=dir('2022*');
for i=1:length(d)
    fprintf('\n%d',i)
    cd(LocalDataRoot)
    cd(d(i).name)
    if exist('Bdirs.mat')==2
        load Bdirs

        masterdir= Bdirs{1};
        if strcmp(masterdir(1:26), DataRoot)
            %             if we're in the master dir, process it and the others
            %             otherwise do nothing
            if strcmp(strrep(masterdir, DataRoot, LocalDataRoot), pwd)
                %we're in master

                %% Load the paths of the experiment folders:
                load('Bdirs.mat'); %This file contains the paths to all the experiment folders that were kilosorted together

                %DataRoot is a variable in Bdirs and dirs that gives the root directory for
                %the data directory as it appeared on the machine that created dirs and
                %Bdirs

                %% Process the spikes:
                fprintf('\nProcess Spikes')
                for idx = 1:length(Bdirs) %For each bonsai folder

                    EphysPath = replace(dirs{idx},DataRoot,LocalDataRoot); %path to Ephys folder
                    if ismac EphysPath=strrep(EphysPath, '\', '/'); end
                    [SortedUnitsFile] = ProcessSpikes(EphysPath,LocalDataRoot); %Process the spikes

                end

                %% Process the cameras:
                fprintf('\nProcess Cams')
                for idx = 1:length(Bdirs) %For each bonsai folder

                    cd(replace(Bdirs{idx},DataRoot,LocalDataRoot)) %Go to the bonsai folder

                    [BehaviorFile] = ProcessCams(Rig); %And run ProcessCams.

                    if isequal(Rig,'Rig2old')
                        load(BehaviorFile); %Now load the behaviorfile
                        [Reye] = ProcessPupil(Reye,0.8); %Calculate the pupil diameter
                        save(BehaviorFile, 'Head', 'Reye', 'Sky'); %And save the info back into the behaviorfile
                    end

                end
            else
                %do nothing
            end

        else
            error('should not fail') %never fails
        end
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