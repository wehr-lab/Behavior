%Necessary data:
%     MusHeadBack
%     MusHeadFront
%     Cricket
%Necessary variables:
%     VideoFs = frame rate of camera (frames/s);
%     Circ structure:
%         Circ.conversion = ratio of centimeters per pixel (cm/pixel);
%         Circ.center = center of arena;
%Optional input:
%     skysaveID:
%         string = saves output as 'outSky_{string}.csv'
%         struct = saves output as {struct.path}\outSky_{struct.string}.csv'
%         anything other than a string or struct = saves output as 'outSky.csv'
%         no input = won't save a csv

function [out] = CalculateMetricsSky(varargin)
%% Define input variables:
MusHeadBack = varargin{1};
MusHeadFront = varargin{2};
Cricket = varargin{3};
VideoFs = varargin{4};
Circ = varargin{5}; ArenaCenter = [Circ.center(1),Circ.center(2)]; conversion = Circ.conversion;

%% Calculate mouse metrics:
    [MusThigmo] = GetDistance(MusHeadBack,ArenaCenter,conversion);
    [MusTheta] = GetAngVelAcl(ArenaCenter,ArenaCenter+[0,1],MusHeadBack,VideoFs);

    [MusBearing,dMusBearing,ddMusBearing] = GetAngVelAcl(MusHeadBack,MusHeadBack+[0,1],MusHeadFront,VideoFs);
    [MusSpeed,MusVxy,MusAxy] = GetSpdVelAcl(MusHeadBack,conversion,VideoFs);
    [MusSpeedPOL,MusVor,MusAor] = GetPolarSpdVelAcl(MusHeadBack,conversion,VideoFs,Circ.center);
    
%% Calculate cricket metrics:
    [CrickThigmo] = GetDistance(Cricket,ArenaCenter,conversion); 
    [CrickTheta] = GetAngVelAcl(ArenaCenter,ArenaCenter+[0,1],Cricket,VideoFs);

    [CrickSpeed,CrickVxy,CrickAxy] = GetSpdVelAcl(Cricket,conversion,VideoFs);
    [~,CrickVor,CrickAor] = GetPolarSpdVelAcl(Cricket(:,1:2),conversion,VideoFs,Circ.center);
    
%% Calculate mouse-cricket metrics:
    [Crange] = GetDistance(MusHeadBack,Cricket,conversion);
    [Azi,dAzi,~] = GetAngVelAcl(MusHeadBack,MusHeadFront,Cricket,VideoFs);
    [MCangle] = GetAngle(ArenaCenter,MusHeadBack,Cricket);
    
%% Package desired metrics into out structure:
    out.MusThigmo = MusThigmo;
    out.CrickThigmo = CrickThigmo;
    out.Azi = Azi;
    out.MusSpeed = MusSpeed;
    out.CrickSpeed = CrickSpeed;
    
    out.Crange = Crange;
    
    out.MusVxy = MusVxy;
    out.CrickVxy = CrickVxy;
    out.MusVor = MusVor;
    out.CrickVor = CrickVor;
    out.MusTheta = MusTheta;
    out.CrickTheta = CrickTheta;
    out.MCangle = MCangle;
    out.MusBearing = MusBearing;
    dMusBearing(abs(dMusBearing)>20)=0;
    out.dMusBearing = dMusBearing;

%% Optionally save the strucure as a CSV table:
    if gt(length(varargin),5)
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
