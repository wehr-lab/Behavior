clear; close all; fclose all;

observationsFileName = '';

%% set your plotting parameters:
ptParam.transform = 'none'; %'xaxis';
ptParam.MarkerSize = 10;
ptParam.alpha = 1;

%% load outputted state frames/samples:
hypotheticalTrials = [1:4,4:20,30:34];
hypotheticalFramerange = 1:60;
for idx = 1:length(hypotheticalTrials)
    States.state1(idx).trial = hypotheticalTrials(idx);
    States.state1(idx).framerange = hypotheticalFramerange;
end
for idx = 1:length(hypotheticalTrials)
    States.state2(idx).trial = hypotheticalTrials(idx);
    States.state2(idx).framerange = hypotheticalFramerange;
end

%% load observations:
load(observationsFileName)

%% plot the data:
fieldnames = fields(States);
numstates = size(fieldnames,1);
for statenum = 1:numstates
    StateName = fieldnames{statenum};
    [fig{statenum}] = PlotStateTracks(df,States.(StateName),ptParam);
    title(['State: ',num2str(statenum)]);
end