%Example script plotting spiketimes, pupildiameter, and SCTs:
test = dir('beh*.mat'); load(test.name);
load('AssimilationWO.mat');
load(strcat(Sky.ephysfolder,'\notebook.mat'));
load(strcat(Sky.ephysfolder,'\SortedUnits.mat')');

%% Original Plot:
allspiketimes = [];
for cellnumber = 1:length(units)
    st = units(cellnumber).spiketimes;
    firstIdx = find(st > units(cellnumber).start,1,'first');
    lastIdx = find(st < units(cellnumber).stop,1,'last');
    spiketimes{cellnumber} = st(firstIdx:lastIdx);
    allspiketimes = [allspiketimes , spiketimes{cellnumber}];
end
PD = (Reye.PupilDiameter(Reye.TTs(1):Reye.TTs(end)));
% subplot(2,1,1);
PupilDiameter = plot(PD,'.','DisplayName','PupilDiameter','MarkerSize',5); hold on
grid on;
xticks(0:60*60:length(PD)); xt = xticks;
xticklabels((xt/Reye.vid.framerate)/60);
ylabel('Pupil Diameter (pixels)','FontSize',25); 

TTs = Reye.TTs(1:end)-Reye.TTs(1);
yvalues = ones(size(TTs))*110;
SCTs = plot(TTs,yvalues,'k.','DisplayName','SCTs','MarkerSize',5);
legend([SCTs,PupilDiameter],'Location','southeast','AutoUpdate','off')

k = 1;
map = colormap(jet(length(units)));
% subplot(2,1,2);
for cellnumber = 1:length(units)
    yvalues = ones(size(spiketimes{cellnumber}))*k;
    plot(spiketimes{cellnumber}*Reye.vid.framerate,yvalues,'.','Color',map(k,:),'MarkerSize',4); hold on;
%     plot(spiketimes{cellnumber}*Reye.vid.framerate,yvalues,'.','MarkerSize',5); hold on;
    k = k+1;
end
xticks(0:60*60:length(PD)); xt = xticks;
xticklabels((xt/Reye.vid.framerate)/60);
% ylabel('Cell Number','FontSize',25); 
xlabel('Time (min)','FontSize',25)
grid on;