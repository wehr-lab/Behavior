%%%%%%For use on rig4. Only works on experiments that were sorted alone
clear; close all;
currentdir = pwd; %remember where we started

%% Determine if we're in ephys or bonsai folder, delete Bdirs, then go to ephys folder
test = dir('*.continuous');
if length(test) < 1 %that means we're in the bonsai folder
    Bdirs = dir('Bdirs.mat'); %so find the Bdirs file %and delete it
    if ~isequal(length(Bdirs),0)
        delete(Bdirs.name); 
    end

    test = dir(); narrowdown = find([test.isdir]); %then find ephys folder
    for k = narrowdown
        testing = strsplit(test(k).name,'_mouse-');
        if length(testing) > 1 %then it is a folder with '_mouse-' in its name, so it's almost certainly the OE folder...
            ephysfolder = strcat(test(k).folder,'\',test(k).name);
        end
    end
    clear test;
    cd(ephysfolder); %and go to the ephys folder

else %we're in the ephys folder
    ephysfolder = pwd;
    cd .. %so back out to the bonsai folder
    Bdirs = dir('Bdirs.mat'); %so find the Bdirs file %and delete it
    if ~isequal(length(Bdirs),0)
        delete(Bdirs.name); 
    end
    clear test;
    cd(ephysfolder); %then go to the ephys folder
end
    
%% Now, delete all the kilosort-generated data, and phy folder + SortedUnits if they have been generated
masterdirs = {ephysfolder};
for i = 1:length(masterdirs)
    cd(masterdirs{i});
    numpys = dir('*.npy');
    dirlist = dir('dirs.mat');
    channelmap = dir('chanMap.mat');
    datfile = dir('OEtetrodes.dat');
    params = dir('params.py');
    recordinglengths = dir('RecLengths.mat');
    clusterlog = dir('cluster_groups.csv');
    phylog = dir('phy.log');
    rez = dir('rez.mat');
    
    KilosortGeneratedData = vertcat(numpys, dirlist, channelmap, datfile, params, recordinglengths, clusterlog, phylog, rez);
    for j = 1:length(KilosortGeneratedData)
        if ~isequal(length(KilosortGeneratedData(j)),0)
            delete(KilosortGeneratedData(j).name);
        end
    end
    
    SortedUnits = dir('SortedUnits.mat');
    if ~isequal(length(SortedUnits),0)
        delete(SortedUnits.name);
    end
    phyautodir = strcat(masterdirs{1}, '\', '.phy');
    if isfolder(phyautodir)
        rmdir(phyautodir, 's');
    end
end

%% Finish up
cd(currentdir); %cd back to whichever directory we started in
clear; %and foget the whole thing ever happened

disp('All kilosort-generated data has been deleted from this experiment folder')