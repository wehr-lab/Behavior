function out=decompose_ear_bearing(varargin)
%decompose right and left ear bearing into a correlated and anti-correlated componenents.
% usage: out=decompose_ear_bearing([BonsaiDir])
%cds to Bonsai dir or defaults to current directory
%expects the following files to be there:
% PreparedHCs_dlc.mat
% Behavior_###.mat
% AssimilationSeg.mat

if nargin==1
    cd(varargin{1})
end
doplot=1; %some plots to inspect the output

out=CalculateMetricsHCs('PreparedHCs_dlc.mat', 60);
BehaviorFileStr = strcat(pwd, filesep, 'Beh*.mat');
BehaviorFile = strcat(pwd,filesep,dir(BehaviorFileStr).name);
load(BehaviorFile);
load AssimilationSeg.mat

%get framebase and align earcam signals
f1=Rear.TTs(1):Rear.TTs(end);
f2=Lear.TTs(1):Lear.TTs(end);
if length(f1)<length(f2)
    f=f1;
else
    f=f2;
end
REA=out.RearBearing(f1(1:length(f)));
LEA=out.LearBearing(f2(1:length(f)));

% substract mean 
msLEA=LEA-mean(LEA); 
msREA=REA-mean(REA); 

%compute projection onto dimension of positive correlation
vectorPos=[-1, -1; 1, 1];
k=0;
for q=[msREA msLEA]'
    k=k+1;
    ProjPos(k,:) = proj(vectorPos, q');
end

%compute projection onto dimension of anti-correlation
vectorNeg=[-1, 1; 1, -1];
k=0;
for q=[msREA msLEA]'
    k=k+1;
    ProjNeg(k,:) = proj(vectorNeg, q');
end

%store in out structure
out.ProjPos=ProjPos;
out.ProjNeg=ProjNeg;
t=f-vids(3).Land;
t=t/Rear.vid.framerate;
out.t=t; %aligned timebase for plotting ear decomposition, in seconds relative to cricket land

if doplot
    %some plots to inspect the output

    figure
    plot(msREA, msLEA, '-o')
    hold on
    plot(vectorPos(:,1), vectorPos(:,2))
    plot(vectorNeg(:,1), vectorNeg(:,2))
    plot(ProjPos(:,1), ProjPos(:,2), 'mo')
    plot(ProjNeg(:,1), ProjNeg(:,2), 'ko')

    figure
    hold on
    plot(t, msLEA+1.5, 'g', t, msREA+1, 'r')
    plot(t, ProjNeg(:,1)+.5,'k', t, ProjPos(:,1), 'm')
    legend('LEar', 'REar', 'anti component', 'corr component')
end %doplot
end

function ProjPoint = proj(vector, q)
p0 = vector(1,:);
p1 = vector(2,:);
a = [-q(1)*(p1(1)-p0(1)) - q(2)*(p1(2)-p0(2)); ...
    -p0(2)*(p1(1)-p0(1)) + p0(1)*(p1(2)-p0(2))];
b = [p1(1) - p0(1), p1(2) - p0(2);...
    p0(2) - p1(2), p1(1) - p0(1)];
ProjPoint = -(b\a);
end