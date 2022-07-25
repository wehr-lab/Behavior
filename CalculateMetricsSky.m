%Optional input:
%     skysaveID:
%         string = saves output as 'outSky_{string}.csv'
%         struct = saves output as {struct.path}\outSky_{struct.string}.csv'
%         anything other than a string or struct = saves output as 'outSky.csv'
%         no input = won't save a csv

function [out] = CalculateMetricsSky(varargin)
%% Define input variables:
MusSpeedPoint = varargin{1};
MusHeadBack = varargin{2};
MusHeadFront = varargin{3};
Cricket = varargin{4};
Sky = varargin{5};
Circ = varargin{6}; ArenaCenter = [Circ.center(1),Circ.center(2)]; conversion = Circ.conversion; %ratio of centimeters per pixel (cm/pixel)
VideoFs = round(Sky.vid.framerate);

%% Calculate mouse metrics:
    [out.MusThigmo] = GetDistance(MusHeadBack,ArenaCenter,conversion);
    [out.MusTheta] = GetAngVelAcl(ArenaCenter,ArenaCenter+[0,1],MusHeadBack,VideoFs);

    [out.MusBearing,out.dMusBearing,ddMusBearing] = GetAngVelAcl(MusHeadBack,MusHeadBack+[0,1],MusHeadFront,VideoFs);
        out.dMusBearing(abs(out.dMusBearing)>20)=0;
    [out.MusSpeed,out.MusVxy,MusAxy] = GetSpdVelAcl(MusSpeedPoint,conversion,VideoFs);
    [MusSpeedPOL,out.MusVor,MusAor] = GetPolarSpdVelAcl(MusSpeedPoint,conversion,VideoFs,Circ.center);
    
%% Calculate cricket metrics if it's a PC trial:
if isfield(Sky.Events,'TerminalCap')
    LF = Sky.Events.TerminalCap;
else
    LF = length(Cricket);
end
if isfield(Sky.Events,'Land') %if it's a PC trial
    FF = Sky.Events.Land;
    
    [CrickThigmo] = GetDistance(Cricket,ArenaCenter,conversion); 
        [out.CrickThigmo] = ClipMetricNaN(CrickThigmo,FF,LF);
    [CrickTheta] = GetAngVelAcl(ArenaCenter,ArenaCenter+[0,1],Cricket,VideoFs); 
        [out.CrickTheta] = ClipMetricNaN(CrickTheta,FF,LF);

    [CrickSpeed,CrickVxy,CrickAxy] = GetSpdVelAcl(Cricket,conversion,VideoFs); 
        [out.CrickSpeed] = ClipMetricNaN(CrickSpeed,FF,LF);
        [out.CrickVxy] = ClipMetricNaN(CrickVxy,FF,LF);
        [CrickAxy] = ClipMetricNaN(CrickAxy,FF,LF);
    [~,CrickVor,CrickAor] = GetPolarSpdVelAcl(Cricket(:,1:2),conversion,VideoFs,Circ.center);
        [out.CrickVor] = ClipMetricNaN(CrickVor,FF,LF);
        [CrickAor] = ClipMetricNaN(CrickAor,FF,LF);

%% Calculate mouse-cricket metrics:
    [Crange] = GetDistance(MusHeadBack,Cricket,conversion);
        [out.Crange] = ClipMetricNaN(Crange,FF,LF);
    [Azi,dAzi,~] = GetAngVelAcl(MusHeadBack,MusHeadFront,Cricket,VideoFs);
        [out.Azi] = ClipMetricNaN(Azi,FF,LF);
        [dAzi] = ClipMetricNaN(dAzi,FF,LF);
    [MCangle] = GetAngle(ArenaCenter,MusHeadBack,Cricket);
        [out.MCangle] = ClipMetricNaN(MCangle,FF,LF);

%% Optionally save the strucure as a CSV table:
    if gt(length(varargin),6)
        skysaveID = varargin{6};
        if ischar(skysaveID)
            outSky = out;
            savename = strcat('outSky_',skysaveID,'.csv');
            Struct2CSV(outSky,savename);
        elseif isstruct(skysaveID)
            outSky = out;
            savename = strcat(skysaveID.path,'\outSky_',skysaveID.string,'.csv');
            Struct2CSV(outSky,savename);
        else %if it's anything other than a string or struct
            outSky = out;
            Struct2CSV(outSky,'outSky.csv');
        end
    end
end

% Function key:
% [midpoint] = GetMidpoints(XYpt1,XYpt2); %output = XYpt
% [distance] = GetDistance(XYpt1,XYpt2,conversion); %output = cm
%     [Spd] = GetSpd(XYpts,conversion,VideoFs); %output = cm/s
%         [Spd,Vel,Acl] = GetSpdVelAcl(XYpts,conversion,VideoFs); %output = cm/s, cm/s, cm/ss
%         [Spd,pVel,pAcl] = GetPolarSpdVelAcl(XYpts,conversion,VideoFs,CircCenter); %output = cm/s, cm/s, cm/ss
% [Ang] = GetAngle(centerXYpt,refXYpt,measureXYpt); %output = angle in radians from -pi to pi
%     [Ang,dAng,ddAng] = GetAngVelAcl(centerXYpt,refXYpt,measureXYpt,VideoFs);
