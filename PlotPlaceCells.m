%% load the assimilation and behavior file
clear all; close all;
load('Assimilation.mat');
behaviorfile = dir('Behavior*.mat');
load(behaviorfile.name);

%% First, plot everywhere the mouse went
SkyStart = vids(find(cellfun(@(v)any(isequal(v,'Sky')),{vids.name}),1)).start;
SkyStop = vids(find(cellfun(@(v)any(isequal(v,'Sky')),{vids.name}),1)).stop;

x = Sky.dlc.Lear(SkyStart:5:SkyStop,1);
y = Sky.dlc.Lear(SkyStart:5:SkyStop,2);
figure; set(gcf,'Position',[1100,75,640,480]);
plot(x,y,'k.','MarkerSize',5,'DisplayName','mouse'); hold on;
set(gca,'YDir','reverse'); axis equal;
xlim([0,1440]); ylim([0,1080]);
title(strcat('All mouse locations for',{' '},Sky.vid.folder))
mkdir placecellplots
saveas(gcf,strcat(pwd,'\placecellplots\AllMouseLocations.png'))

%% Next, get spiketimes of each unit and their closest corresponding video frame
allspiketimes = [];
for cellnumber = 1:length(units)
    st = units(cellnumber).spiketimes;
    firstIdx = find(st > units(cellnumber).start,1,'first');
    lastIdx = find(st < units(cellnumber).stop,1,'last');
    spiketimes{cellnumber} = st(firstIdx:lastIdx);
    allspiketimes = [allspiketimes , spiketimes{cellnumber}];
end
[DLCframes] = ThisToThat('OE',allspiketimes*units(1).sampleRate,'Sky'); %This step will take a little bit if you have many thousands of events, frames, and spiketimes

%% Then, plot where the mouse was at for each spiketime of each unit and save the figures in a new folder
currentspikenumber = 1;
for cellnumber = 1:length(units)
    currentrange = (currentspikenumber:(currentspikenumber+length(spiketimes{cellnumber}))-1);
    x = Sky.dlc.Lear(DLCframes(currentrange),1);
    y = Sky.dlc.Lear(DLCframes(currentrange),2);
    plot(x,y,'.','MarkerSize',10);
    set(gca,'YDir','reverse'); axis equal;
    xlim([0,1440]); ylim([0,1080]);
    title({strcat('cell#', num2str(cellnumber),' channel: ',num2str(units(cellnumber).channel)),Sky.vid.folder});
    
    %%%%% save a picture of the plot:
    saveas(gcf,strcat(pwd,'\placecellplots\','cellnum', num2str(cellnumber),'_channel',num2str(units(cellnumber).channel),'.png'))
    close;
    %%%%% append the aligned video frames for each spiketime of this unit
    units(cellnumber).spikeframes = DLCframes(currentrange);    
    
    currentspikenumber = currentspikenumber+length(spiketimes{cellnumber});
end
save('ProcessedInformation.mat','Sky','vids','units','chans');