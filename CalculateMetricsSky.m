%Necessary variables:
%     conversion = ratio of centimeters per pixel (cm/pixel);
%     VideoFs = frame rate of camera (frames/s);
%Necessary data:
%     cricketXYpts
%     mousenoseXYpts
%     mousepivotXYpts

% [midpoint] = GetMidpoints(XYpt1,XYpt2); %output = XYpt
% [distance] = GetDistance(XYpt1,XYpt2,conversion); %output = distance (cm)
%     [Spd] = GetSpd(XYpts,conversion,VideoFs); %output = cm/s
%         [Spd,Vel,Acl] = GetSpdVelAcl(XYpts,conversion,VideoFs);
%         [Spd,pVel,pAcl] = GetPolarSpdVelAcl(XYpts,conversion,VideoFs,CircCenter);
% [Ang] = GetAngle(centerXYpt,refXYpt,measureXYpt); %output = angle in radians from -pi-to-pi
%     [Ang,dAng,ddAng] = GetAngVelAcl(centerXYpt,refXYpt,measureXYpt,VideoFs);


%% SkyStuff:
    %%Mouse metrics:
        [s1.t.Earmdpt] = GetMidpoints(s1.t.LCback,s1.t.RCback);
        [MusThigmo] = GetDistance(s1.t.Earmdpt,s1.Circ.center',s1.Circ.conversion);
        ArenaCenters = [s1.Circ.center(1),s1.Circ.center(2)];
        [MusTheta] = GetAngVelAcl(ArenaCenters,ArenaCenters+[0,1],s1.t.Earmdpt,SkyFs);
        
        [MusBearing,vMusBearing,dvMusBearing] = GetAngVelAcl(s1.t.BackOfHead,s1.t.BackOfHead+[0,1,0],s1.t.HCleft,SkyFs);
        [MusSpeed,MusV,MusA] = GetSpdVelAcl(s1.t.Earmdpt,s1.Circ.conversion,SkyFs);
        [MusSpeedPOL,MusVPOL,MusAPOL] = GetPolarSpdVelAcl(s1.t.Earmdpt,s1.Circ.conversion,SkyFs,s1.Circ.center);
    %%Cricket metrics:
        [CrickThigmo] = GetDistance(s1.t.Cpost,s1.Circ.center',s1.Circ.conversion);
%         [CrickThigmo] = GetDistance(s1.t.Cant,s1.Circ.center',s1.Circ.conversion);
        [CrickTheta] = GetAngVelAcl(ArenaCenters,ArenaCenters+[0,1],s1.t.Cpost,SkyFs);

        [CrickSpeed,CrickV,CrickA] = GetSpdVelAcl(s1.t.Cpost,s1.Circ.conversion,SkyFs);
        [CrickSpeedPOL,CrickVPOL,CrickAPOL] = GetPolarSpdVelAcl(s1.t.Cpost(:,1:2),s1.Circ.conversion,SkyFs,s1.Circ.center);
    %%Mouse-Cricket metrics:
        [Crange] = GetDistance(s1.t.BackOfHead,s1.t.Cpost,s1.Circ.conversion);
        [Azimuth,~,~] = GetAngVelAcl(s1.t.BackOfHead,s1.t.HCleft,s1.t.Cpost,SkyFs);
        [MCangle,~,~] = GetAngVelAcl(s1.t.BackOfHead,s1.t.BackOfHead+[0,1,0],s1.t.Cpost,SkyFs);
    %%Clip Cricket values:
        [CrickThigmo] = ClipMetricNaN(CrickThigmo,Sky.FF,Sky.LF);
        [CrickSpeed] = ClipMetricNaN(CrickSpeed,Sky.FF,Sky.LF);
        [CrickV] = ClipMetricNaN(CrickV,Sky.FF,Sky.LF); [CrickA] = ClipMetricNaN(CrickA,Sky.FF,Sky.LF);
        [CrickVPOL] = ClipMetricNaN(CrickVPOL,Sky.FF,Sky.LF); [CrickAPOL] = ClipMetricNaN(CrickAPOL,Sky.FF,Sky.LF);
        [Crange] = ClipMetricNaN(Crange,Sky.FF,Sky.LF);
        [Azimuth] = ClipMetricNaN(Azimuth,Sky.FF,Sky.LF);
        [MCangle] = ClipMetricNaN(MCangle,Sky.FF,Sky.LF);
    %%Package outSky structure:
        outSky.MusThigmo = MusThigmo(Sky.FF:Sky.LF);
        outSky.CrickThigmo = CrickThigmo(Sky.FF:Sky.LF);
        outSky.Crange = Crange(Sky.FF:Sky.LF);
        outSky.MusTheta = MusTheta(Sky.FF:Sky.LF);
        outSky.CrickTheta = CrickTheta(Sky.FF:Sky.LF);
        outSky.vMusBearing = vMusBearing(Sky.FF:Sky.LF);
        
        outSky.Azimuth = Azimuth(Sky.FF:Sky.LF);
        outSky.MCangle = MCangle(Sky.FF:Sky.LF);

        outSky.MusSpeed = MusSpeed(Sky.FF:Sky.LF);
        outSky.CrickSpeed = CrickSpeed(Sky.FF:Sky.LF);

        outSky.MusV = MusV(Sky.FF:Sky.LF,:);
        outSky.CrickV = CrickV(Sky.FF:Sky.LF,:);

        outSky.MusVp = MusVPOL(Sky.FF:Sky.LF,:);
        outSky.CrickVp = CrickVPOL(Sky.FF:Sky.LF,:);