function [obj] = PlotRadialOccupancy(varargin)
%input1: RhoValues = radial values (cm)
%input2: Fs = framerate
%input3: param = plotting parameters (optional)
    %param.edges = edges specifying the binning (ex: 0:1:30)
    %param.yaxis = 'seconds' or 'percent occupancy'

RhoValues = varargin{1};        %radial values (cm)
Fs = varargin{2};               %framerate
if gt(length(varargin),2)
    param = varargin{3};
else
    param.edges = 0:1:30;       %default values
    param.yaxis ='seconds';
end

[N] = histcounts(RhoValues,param.edges);
binlocations = param.edges(1:end-1) + diff(param.edges) / 2;
occupancy = N/Fs;
totalTime = length(RhoValues)/Fs;

fig = figure;
if isequal(param.yaxis,'seconds')
    obj = plot(binlocations,occupancy,'-'); hold on
    ylabel('occupancy (s)')
elseif isequal(param.yaxis,'percent')
    obj = plot(binlocations,occupancy/totalTime,'-'); hold on
    ylabel('percent occupancy')
end
xlabel('radial position (cm)')
text(0.1,0.9,['total time : ',num2str(totalTime),'s'],'Units','normalized','BackgroundColor','w','EdgeColor','k')
grid minor;
end