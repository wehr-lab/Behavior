function [clippedMetric] = ClipMetricNaN(varargin)
metric = varargin{1}; firstFrame = varargin{2};
metric(1:firstFrame-1,:) = nan;
if isequal(length(varargin),3)
    EndingIdx = varargin{3};
    metric(EndingIdx+1:end,:) = nan;
end
clippedMetric = metric;
end