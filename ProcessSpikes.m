function [SortedUnits,sampleRate] = ProcessSpikes()
    if exist('dirs.mat','file')
        datadir = pwd;
        load('dirs.mat')
        masterdir=dirs{1};
        if ismac masterdir=macifypath(masterdir);end
        sp = loadKSdir(masterdir);
        
        %These two lines adapted from: https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/phy-users/Ydu1etOXwF0/-vEM9Rx_BgAJ
        tempChannelAmps = squeeze(max(sp.temps,[],2))-squeeze(min(sp.temps,[],2)); % amplitude of each template on each channel, size nTemplates x nChannels
        [~,maxChannel] = max(tempChannelAmps,[],2); % index of the largest amplitude channel for each template, size nTemplates x 1
        
        cd(datadir);
        
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

                channel=fn(1,1); clust=fn(1,2); cellnum=fn(1,3);

                spiketimes=readKiloSortOutput(clust, sp.sample_rate);

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
        save SortedUnits SortedUnits sampleRate
    end
end


