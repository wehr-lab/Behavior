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
figure; set(gcf,'Position',[1100,75,800,800]);
plot(x,y,'k.','MarkerSize',5,'DisplayName','mouse'); hold on;
xlim([0,1440]); ylim([0,1080]); 
set(gca,'Position',[0.05, 0.275, 0.9, 0.9*0.75],'YDir','reverse');

%% Then, plot where the mouse was at for each spiketime of each unit
c = parula(length(units));
for cellnumber = 1:length(units)
    spiketimes = units(cellnumber).spiketimes;
    firstIdx = find(spiketimes > units(cellnumber).start,1,'first');
    lastIdx = find(spiketimes < units(cellnumber).stop,1,'last');
    
    [DLCframes] = ThisToThat('OE',spiketimes(firstIdx:lastIdx)*units(cellnumber).sampleRate,'Sky'); close;

    x = Sky.dlc.nose(DLCframes(:),1);
    y = Sky.dlc.nose(DLCframes(:),2);
    plot(x,y,'.','MarkerSize',15,'LineWidth',2,'Color',c(cellnumber,:),'DisplayName',strcat('cell#', num2str(cellnumber),' channel: ',num2str(units(cellnumber).channel)));

end
legend