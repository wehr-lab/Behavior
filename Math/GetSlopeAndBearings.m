function [slope,Bearing,vBearing,dvBearing] = GetSlopeAndBearings(varargin)
x1 = varargin{1}(:,1); x2 = varargin{2}(:,1);
y1 = varargin{1}(:,2); y2 = varargin{2}(:,2);
Fs = varargin{3};
slope = (y2-y1)/(x2-x1);
Bearing = atan2d(y2-y1,x2-x1);

%smooth and unwrap by default
% Bearing = smooth(Bearing,5,'rloess');
Bearing = unwrap(Bearing);
% Bearing = lowpass(Bearing,2,Fs);

vBearing = zeros(size(Bearing));
vBearing(1) = nan;
vBearing(1:end-1) = diff(Bearing);
vBearing(end) = nan;

dvBearing = zeros(size(vBearing));
dvBearing(1) = nan;
dvBearing(1:end-1) = diff(vBearing);
dvBearing(end) = nan;

vBearing = vBearing*Fs;
dvBearing = dvBearing*Fs;
end