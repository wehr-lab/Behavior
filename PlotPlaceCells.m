%% load the assimilation and behavior file
clear all; close all;
%load('Assimilation.mat');
behaviorfile = dir('Behavior*.mat').name;
load(behaviorfile);

WalkFilter = 1;
ToSmoothOrNot = 1;
alphavalue = 1; %1 for normal transparency
SizeData = 5; %10 for normal
XYpt = Sky.dlc.tailbase; %the dlc-point you want to use
    pThresh = 0.8; %dlc-probability threshold for 'good' frames
    SmoothValue = 75;
    tic
    XYpt = CleanTrack(XYpt,pThresh,SmoothValue,ToSmoothOrNot); %drops bad frames, interpolates, and smooths
    toc

%% First, plot everywhere the mouse went
SkyStart = vids(find(cellfun(@(v)any(isequal(v,'Sky')),{vids.name}),1)).start;
SkyStop = vids(find(cellfun(@(v)any(isequal(v,'Sky')),{vids.name}),1)).stop;

x = XYpt(SkyStart:5:SkyStop,1);
y = XYpt(SkyStart:5:SkyStop,2);
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

%% New: optionally make a 'walk filter' with threshold of 2cm/s
if isequal(WalkFilter,1)
    Pixel_CM_Conversion = 0.06295908; %cm/pixels in rig4
    [Spd] = GetSpeed(XYpt,Pixel_CM_Conversion,Sky.vid.framerate); Spd = [nan;Spd];
    MovingFrames = find(Spd>2);
end

%% Then, plot where the mouse was at for each spiketime of each unit and save the figures in a new folder
currentspikenumber = 1;
for cellnumber = 1:length(units)
    currentrange = (currentspikenumber:(currentspikenumber+length(spiketimes{cellnumber}))-1);
    FramesToPlot = DLCframes(currentrange);
        if isequal(WalkFilter,1)
            MovingIdx = ismember(FramesToPlot,MovingFrames);
            originalLength = length(FramesToPlot);
            FramesToPlot = FramesToPlot(MovingIdx);
            FrameDifference = originalLength-length(FramesToPlot);
        end
    x = XYpt(FramesToPlot,1);
    y = XYpt(FramesToPlot,2);
    if isequal(WalkFilter,1)
        plotobj = scatter(x,y,'SizeData',SizeData,'MarkerFaceColor','k','MarkerEdgeColor','k'); %Poor-man's heatplot using alpha values (currently not working)
        plotobj.MarkerEdgeAlpha = alphavalue;
        plotobj.MarkerFaceAlpha = alphavalue;
    else
        plot(x,y,'.','MarkerSize',10);
    end
    set(gca,'YDir','reverse'); axis equal;
    xlim([0,1440]); ylim([0,1080]);
    if isequal(WalkFilter,1)
        title({strcat('cell#', num2str(cellnumber),' channel: ',num2str(units(cellnumber).channel)),num2str(FrameDifference),Sky.vid.folder});
    else
        title({strcat('cell#', num2str(cellnumber),' channel: ',num2str(units(cellnumber).channel)),Sky.vid.folder});
    end
    %%%%% save a picture of the plot:
    saveas(gcf,strcat(pwd,'\placecellplots\','cellnum', num2str(cellnumber),'_channel',num2str(units(cellnumber).channel),'.png'))
    close;
    %%%%% append the aligned video frames for each spiketime of this unit
    units(cellnumber).spikeframes = DLCframes(currentrange);    
    
    currentspikenumber = currentspikenumber+length(spiketimes{cellnumber});
end
save('ProcessedInformation.mat','Sky','vids','units','chans');

function [XYpt] = CleanTrack(XYpt,pThresh,SmoothValue,ToSmoothOrNot)
pValues = XYpt(:,3);
GoodFrames = pValues > pThresh;
[newGoodFrames] = RemoveSpuriousGoodFrames(GoodFrames); 
x = find(newGoodFrames);

%Interpolate:
PoorFrames = ones(size(pValues)); PoorFrames(x) = 0;
xq = find(PoorFrames);
vq1 = [];
newpts = XYpt;
for k = 1:2 %X and Y
    v = XYpt(:,k);
    v = v(x);
    try %sometimes there aren't good frames, which causes an error
        vq1(:,k) = interp1(x,v,xq);
        newpts(xq,k) = vq1(:,k);
    catch
    end
end
XYpt = newpts;
nanframes = find(isnan(XYpt(:,1)));
XYpt(nanframes,1) = 0;
XYpt(nanframes,2) = 0;
% % % XYpt(xq,:) = nan;

if isequal(ToSmoothOrNot,1)
%Smooth:
% XYpt(:,1) = smooth(XYpt(:,1),SmoothValue,'loess');
% XYpt(:,2) = smooth(XYpt(:,2),SmoothValue,'loess');
XYpt(:,1)=fastsmooth(XYpt(:,1),SmoothValue,1,1);
XYpt(:,2)=fastsmooth(XYpt(:,2),SmoothValue,1,1);
end

% newXYP = [XYpt,pValues];
% XYpt = newXYP;
end

function [newGoodFrames] = RemoveSpuriousGoodFrames(GoodFrames)
newGoodFrames = GoodFrames;
x = find(GoodFrames);
try
    if isequal(x(1),1) %remove first frame if present
       x = x(2:end); 
    end
    if isequal(x(end),length(GoodFrames)) %remove last frame if present
       x = x(1:end-1); 
    end
end
for i = 1:length(x)
    idx = x(i);
    test = (GoodFrames(idx-1)+GoodFrames(idx+1));
    if isequal(test,0) %if this good frame is flanked by bad frames, label it a bad frame
        newGoodFrames(idx) = 0;
    end
end
end