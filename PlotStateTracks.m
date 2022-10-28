function [fig] = PlotStateTracks(df,statestruct,ptParam)

obj = []; fig = figure;
for idx = 1:length(statestruct)
    trial = statestruct(idx).trial;
    framerange = statestruct(idx).framerange;
    [obj] = PlotStateTracksSingle(df(trial).dsWO,framerange,ptParam,obj);
end

end

function [obj] = PlotStateTracksSingle(data,framerange,param,obj)
%% inputs:
    %data = structure with the data for that particular trial (ex: df(4).dsWO)
    %framerange = particular frames/samples from the trial to plot
    %pltParam = structure with plotting instructions
    %obj = plotting objects

%% transforming the data:
if isequal(param.transform,'xaxis')
    initialRotation = data.MusTheta(framerange(1));
    MusTheta = data.MusTheta(framerange)-initialRotation;
    CrickTheta = data.CrickTheta(framerange)-initialRotation;
else
    MusTheta = data.MusTheta(framerange);
    CrickTheta = data.CrickTheta(framerange);
end
MusRho = data.MusRho(framerange);
CrickRho = data.CrickRho(framerange);

%% plotting:
if isempty(obj) %plot being initialized
    Plotting_idx = 1;
    th = linspace(0,2*pi,50); r = 30;
    polarplot(th,r+zeros(size(th)),'k'); hold on;
else %plot being appended
    Plotting_idx = size(obj,2)+1;
end

obj{Plotting_idx}.Mus = polarscatter(MusTheta,MusRho,param.MarkerSize,'blue','filled','AlphaData',param.alpha);
    obj{Plotting_idx}.Mus.MarkerEdgeAlpha = param.alpha;
    obj{Plotting_idx}.Mus.MarkerFaceAlpha = param.alpha;
obj{Plotting_idx}.Crick = polarscatter(CrickTheta,CrickRho,param.MarkerSize,'green','filled','AlphaData',param.alpha);
    obj{Plotting_idx}.Crick.MarkerEdgeAlpha = param.alpha;
    obj{Plotting_idx}.Crick.MarkerFaceAlpha = param.alpha;

if isequal(Plotting_idx,1) %format the axis
    ax = gca;
    ax.RLim = [0,33]; rlim('manual');
    ax.RTick = [0,10,20,30]; ax.RTickLabel = {}; %ax.RTickLabel = {'','','','30cm'};
    text((pi/2)-0.12,31.5,'30cm');

    ax.ThetaTick = [0 45 90 135 180 225 270 315]; %ax.ThetaTick = [0 90 180 270];
    ax.ThetaTickLabel = {'0^{\circ}','','90^{\circ}','','180^{\circ}','','270^{\circ}',''};

    legend([obj{Plotting_idx}.Mus,obj{Plotting_idx}.Crick],{'Mouse','Cricket'},'Location','none','Position',[0.75 0.8238 0.1589 0.0869],'AutoUpdate','off');
end
end