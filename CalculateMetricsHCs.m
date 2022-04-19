function [outHCs] = CalculateMetricsHCs(filename,AnalogFs)
%inputs: PreparedHCs filename, and camera framerate (AnalogFs)
load(filename);
    %%HeadStuff:
        [NasLine] = AverageAndMidpoint(h1.t.lNasal(:,1:2),h1.t.rNasal(:,1:2));

        [NWBearing,vNWBearing,dvNWBearing] = GetAngVelAcl(NasLine(2,:),NasLine(2,:)+[0,1],h1.t.NW(:,1:2),AnalogFs);
        [NEBearing,vNEBearing,dvNEBearing] = GetAngVelAcl(NasLine(2,:),NasLine(2,:)+[0,1],h1.t.NE(:,1:2),AnalogFs);
        [rtBearing,vtrBearing,dvtrBearing] = GetAngVelAcl(NasLine(2,:),NasLine(2,:)+[0,1],h1.t.lMyst1(:,1:2),AnalogFs);
        
    %%LearStuff:
        l1.learorigin = [0,-350];
        [LearBearing,vLearBearing,dvLearBearing] = GetAngVelAcl(l1.learorigin(:,1:2),l1.learorigin(:,1:2)+[0,-1],l1.t.post2(:,1:2),AnalogFs);
    %%RearStuff:
        r1.rearorigin = l1.learorigin;
        [RearBearing,vRearBearing,dvRearBearing] = GetAngVelAcl(r1.rearorigin(:,1:2),r1.rearorigin(:,1:2)+[0,-1],r1.t.post2(:,1:2),AnalogFs);

%This puts angles of ears into protraction and retraction:
%         RearBearing = RearBearing*-1; 
%         vRearBearing = vRearBearing*-1;
%         dvRearBearing = dvRearBearing*-1;
    
    %%Package outHCs structure:
    outHCs.LearBearing = LearBearing;
    outHCs.vLearBearing = vLearBearing;
    outHCs.dvLearBearing = dvLearBearing;

    outHCs.RearBearing = RearBearing;
    outHCs.vRearBearing = vRearBearing;
    outHCs.dvRearBearing = dvRearBearing;

    outHCs.NEBearing = NEBearing;
    outHCs.vNEBearing = vNEBearing;
    outHCs.dvNEBearing = dvNEBearing;

    outHCs.NWBearing = NWBearing;
    outHCs.vNWBearing = vNWBearing;
    outHCs.dvNWBearing = dvNWBearing;

end

%Space/time variables:
%     conversion = ratio of centimeters per pixel (cm/pixel);
%     VideoFs = frame rate of camera (frames/s);

%Functions key:
% [midpoint] = GetMidpoints(XYpt1,XYpt2); %output = XYpt
% [distance] = GetDistance(XYpt1,XYpt2,conversion); %output = distance (cm)
%     [Spd] = GetSpd(XYpts,conversion,VideoFs); %output = cm/s
%         [Spd,Vel,Acl] = GetSpdVelAcl(XYpts,conversion,VideoFs);
%         [Spd,pVel,pAcl] = GetPolarSpdVelAcl(XYpts,conversion,VideoFs,CircCenter);
% [Ang] = GetAngle(centerXYpt,refXYpt,measureXYpt); %output = angle in radians from -pi-to-pi
%     [Ang,dAng,ddAng] = GetAngVelAcl(centerXYpt,refXYpt,measureXYpt,VideoFs);