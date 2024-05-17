function [SortedUnitsFile] = ProcessSpikes(varargin)
%load kilosorted spiking data and put into SortedUnits structure and write to SortedUnits.mat file
%usage: 
% [SortedUnitsFile] = ProcessSpikes(EphysPath,LocalDataRoot) (works for older data format with earlier versions of open ephys and kilosort
% [SortedUnitsFile] = ProcessSpikes(BonsaiPath, EphysPath_KS, EphysPath, LocalDataRoot) (new data format with new versions of open ephys and kilosort
%
% in the new OE format, I think it only makes sense to call ProcessSpikes
% on the EphysPath_KS pointing to the MasterDir


switch nargin
    case 2 %old way
        EphysPath=varargin{1};
        LocalDataRoot=varargin{2};
        BonsaiAndDirname = erase(EphysPath,{LocalDataRoot}); %Bdir and dir
        test = strrep(BonsaiAndDirname,'\','SplitString');
        test = strrep(test,'/','SplitString'); %forward slash if unix
        test = strsplit(test,'SplitString');
        BdirName = test{1}; %name of Bonsai folder
        dirName = test{2}; %name of Ephys folder

        TestPath = strrep(EphysPath,LocalDataRoot,DataRoot);
        currentdir_indx=find(strcmp(TestPath, dirs)==1); %which dir are we trying to plot?
        if currentdir_indx==0
            error('This directory cannot be found on the list of clustered directories. \n Either this data has not been clustered or something bad happened')
        end

        try
            load(fullfile(EphysPath,'dirs.mat'));
        catch
            try
                [tempEphysPath,~,~]=fileparts(EphysPath);
                load(fullfile(tempEphysPath,'dirs.mat'));
            catch
                error('Could not find dirs.mat. Please call SettingYourStage to select the data directories from this session which will create bdirs and dirs .mat files')
            end
        end
        MasterDir = replace(dirs{1},DataRoot,LocalDataRoot); %The path to the master ephys folder
        if ismac MasterDir=macifypath(MasterDir);end

    case 4 %new way

        BonsaiPath=varargin{1};
        EphysPath_KS=varargin{2};
        EphysPath=varargin{3};
        LocalDataRoot=varargin{4};
        DataRoot=LocalDataRoot; % maybe we need to extract DataRoot from dirs? It comes into play if we are calling ProcessSpikes on a different machine from where dirs was created
        load(fullfile(BonsaiPath, EphysPath,'dirs.mat'));
        MasterDir = EphysPath_KS; %The path to the master ephys KS folder
        if ismac MasterDir=macifypath(MasterDir);end
        currentdir_indx=find(strcmp(fullfile(BonsaiPath,EphysPath), dirs)); %which dir are we trying to plot?
        BdirName=BonsaiPath;
        dirName=EphysPath;
end





sp = loadKSdir(MasterDir); 
%LoadKSdir is from the "spikes" repository https://github.com/cortex-lab/spikes
% which in turn requires the npy-matlab repository https://github.com/kwikteam/npy-matlab

%These two lines adapted from: https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/phy-users/Ydu1etOXwF0/-vEM9Rx_BgAJ
tempChannelAmps = squeeze(max(sp.temps,[],2))-squeeze(min(sp.temps,[],2)); % amplitude of each template on each channel, size nTemplates x nChannels
[~,maxChannel] = max(tempChannelAmps,[],2); % index of the largest amplitude channel for each template, size nTemplates x 1

%sp.cids are the kilosort cell IDs which you didn't label as noise. Found in 'cluster_groups.csv'
for i=1:length(sp.cids) %each iteration here therefore corresponds to the 'cellnum' used in readKiloSortOutput.
    if ~isequal(sp.cgs(i),3) %if the cell has been sorted, proceed to read out its information
        template = []; Utemplate = []; numUtemplate = [];
        template = sp.spikeTemplates(sp.clu==sp.cids(i)); %identifies the template for every spike in this cluster/cell_ID
        Utemplate = unique(template); %identify all the unique templates contained in this cluster/cell_ID
        if isempty(Utemplate)
            error('no spikes match the cluster ids, this should not happen and could indicate an faulty kilosort run');
        end
        if length(Utemplate) == 1 %If the cluster contains spikes from only one template
            template = ((template(1,1))+1); %then use this template (+1 because they are indexed from 0:nTemplates-1 and maxChannel is 1:nTemplates)
            chan = maxChannel(template,1); %retun the channel that was identified to have the highest amplitude for this template
        else
            for k = 1:length(Utemplate) %If the cluster contains spikes from more than one template
                numUtemplate(k,1) = sum(template(:) == Utemplate(k,1)); %find how many spikes in this cluster/cell_ID there are, for each template 
                [val, idx] = max(numUtemplate); %find which template is most prevalent
                template = (Utemplate(idx,1)+1); %use this template (+1 because they are indexed from 0 and maxChannel is indexed 1:nTemplates)
                chan = maxChannel(template,1); %retun the channel that was identified to have the highest amplitude for this template
            end
        end
        chan = chan - 1;
        %fn is normally the name of the .t file
        %In the case of Kilosort data however, readKiloSortOutput is used in the Process_single
        %function instead, and instead of using any .t files, it requires the
        %'cellnum' which it uses to iterate through the non-noise clusters in 'cluster_groups.csv'
        %So for now at least, I have fn = [channel, clust, cellnum]
        fn= [chan,sp.cids(i),i];

        channel = fn(1,1); clust = fn(1,2); cellnum = fn(1,3);

        spiketimes = readKiloSortOutput2(clust, sp, currentdir_indx, MasterDir);

        SortedUnits(i).cellnum = i;
        SortedUnits(i).channel = chan;
        SortedUnits(i).cluster = sp.cids(i);
        SortedUnits(i).spiketimes = spiketimes;
        if isequal(sp.cgs(i),2)
            SortedUnits(i).rating = 'good';
        elseif isequal(sp.cgs(i),1)
            SortedUnits(i).rating = 'multiunit';
        end
    end
end

sampleRate = sp.sample_rate;

for unit = 1:length(SortedUnits)
    SortedUnits(unit).dir_indx = currentdir_indx;
    SortedUnits(unit).Bdir = BdirName;
    SortedUnits(unit).dir = dirName;
    SortedUnits(unit).ProcessSpikesDataRoot = LocalDataRoot; %DataRoot of where ProcessSpikes was just ran
    SortedUnits(unit).KilosortedDataRoot = DataRoot; %DataRoot of where kilosort was ran
end
switch nargin
    case 2 %old way

        savename = strcat('SortedUnits_',BdirName,'.mat');
        SortedUnitsFile = fullfile(EphysPath,savename);
        save(SortedUnitsFile, 'SortedUnits', 'sampleRate'); %Saves SortedUnits & sampleRate as 'SortedUnits.mat' in the ephys folder
    case 4 %new way
                savename = strcat('SortedUnits_',EphysPath,'.mat');
        SortedUnitsFile = fullfile(BonsaiPath,EphysPath,savename);
        save(SortedUnitsFile, 'SortedUnits', 'sampleRate'); %Saves SortedUnits & sampleRate as 'SortedUnits.mat' in the ephys folder

end
end


