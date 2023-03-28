function [out] = CalculateMetricsSkyNew(varargin)
%% Define input variables:
MusSpeedPoint = varargin{1};    %mouse point you want to use to calculate speed (usually a body point or the back of the head)
MusHeadBack = varargin{2};      %mouse point you want to use as the vertex for bearing/azimuth calculations (usually the back of the head)
MusHeadFront = varargin{3};     %mouse point you want to use as the reference point for bearing/azimuth calculations (usually the nose)
Cricket = varargin{4};          %cricket point you want to use for all calculations
Sky = varargin{5};              %Sky structure
Circ = varargin{6};             %Circ structure

%%
ArenaCenter = [Circ.center(1),Circ.center(2)]; 
conversion = Circ.conversion;           %ratio of centimeters per pixel (cm/pixel)
VideoFs = round(Sky.vid.framerate);     %Sky framerate

%% Calculate mouse metrics:
    [out.MusTheta,out.MusRho] = GetPolarCoordinates(ArenaCenter,MusHeadBack,conversion);
        out.MusThigmo = 30-out.MusRho;
    
    [out.MusSpeed,MusVxy,MusAxy] = GetSpdVelAcl(MusSpeedPoint,conversion,VideoFs);
        out.MusVx = MusVxy(:,1); out.MusVy = MusVxy(:,2);
        out.MusAx = MusAxy(:,1); out.MusAy = MusAxy(:,2);
    [~,MusVor,MusAor] = GetPolarSpdVelAcl(MusSpeedPoint,conversion,VideoFs,Circ.center);
        out.MusVorb = MusVor(:,1); out.MusVrad = MusVor(:,2);
        out.MusAorb = MusAor(:,1); out.MusArad = MusAor(:,2);
    [out.MusBearing,out.dMusBearing,ddMusBearing] = GetAngVelAcl(MusHeadBack,MusHeadBack+[0,1],MusHeadFront,VideoFs);
    
    
%% Calculate cricket metrics if it's a PC trial:
if isfield(Sky.Events,'Land') %it's a PC trial

    [out.CrickTheta,out.CrickRho] = GetPolarCoordinates(ArenaCenter,Cricket(:,1:2),conversion);
        out.CrickThigmo = 30-out.CrickRho;
    
    [out.CrickSpeed,CrickVxy,CrickAxy] = GetSpdVelAcl(Cricket,conversion,VideoFs);
        out.CrickVx = CrickVxy(:,1); out.CrickVy = CrickVxy(:,2);
        out.CrickAx = CrickAxy(:,1); out.CrickAy = CrickAxy(:,2);
    [~,CrickVor,CrickAor] = GetPolarSpdVelAcl(Cricket(:,1:2),conversion,VideoFs,Circ.center);
        out.CrickVorb = CrickVor(:,1); out.CrickVrad = CrickVor(:,2);
        out.CrickAorb = CrickAor(:,1); out.CrickArad = CrickAor(:,2);

%% Calculate mouse-cricket metrics:
    [out.Range] = GetDistance(MusHeadBack,Cricket,conversion);
    
    [RangeMidpt] = GetMidpoints(MusHeadBack,Cricket);
    [out.RangeTheta,out.RangeRho] = GetPolarCoordinates(ArenaCenter,RangeMidpt,conversion);

    [newRefX,newRefY] = pol2cart(out.RangeTheta,out.RangeRho*2); newRef = [newRefX,newRefY];
    [out.RangePhi] = GetAngVelAcl(RangeMidpt,newRef,MusHeadBack,VideoFs);
        out.RangePhi = out.RangePhi*-1;
    [out.RangePhiXY] = GetPolarCoordinates(RangeMidpt,MusHeadBack,conversion);

    [out.Azi,out.dAzi,~] = GetAngVelAcl(MusHeadBack,MusHeadFront,Cricket,VideoFs);

end

%% Optionally save the strucure as a CSV table:
if gt(length(varargin),6) %will save a csv if there are 7 inputs
    skysaveID = varargin{6};
    if ischar(skysaveID) %string = saves output as 'outSky_{string}.csv'
        outSky = out;
        savename = strcat('outSky_',skysaveID,'.csv');
        Struct2CSV(outSky,savename);
    elseif isstruct(skysaveID) %struct = saves output as {struct.path}\outSky_{struct.string}.csv'
        outSky = out;
        savename = strcat(skysaveID.path,'\outSky_',skysaveID.string,'.csv');
        Struct2CSV(outSky,savename);
    else %if it's anything other than a string or struct, it will save output as 'outSky.csv'
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

function [Theta,Rho] = GetPolarCoordinates(vertex,points,conversion)
temp = points-vertex;
[Theta,~] = cart2pol(temp(:,1),temp(:,2)); 
[Rho] = GetDistance(points,vertex,conversion);
end