function PlotPreyCaptures(varargin)
close all
load('dirs.mat');
masterdir = dirs{1};
for i = 1:length(dirs)
    cd(dirs{i});
    Flow
end
cd(masterdir)
end

