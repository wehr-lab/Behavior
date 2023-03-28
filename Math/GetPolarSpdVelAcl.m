function [Spd,pVel,pAcl] = GetPolarSpdVelAcl(XYpts,conversion,VideoFs,CircCenter)
[~,Vel,~] = GetSpdVelAcl(XYpts,conversion,VideoFs);
[Th,Rh] = Convert2Polar(XYpts,CircCenter);

r1 = Rh(1:end-1); r2 = Rh(2:end);
Spd = sqrt((r1.*r1) + (r2.*r2) - 2*(r1.*r2).*cos(diff(Th)) );
Spd = (Spd*conversion)*VideoFs;

Thvel = -Vel(:,1).*sin(Th) + Vel(:,2).*cos(Th);
Rhvel = Vel(:,1).*cos(Th) + Vel(:,2).*sin(Th);
pVel = [Thvel,Rhvel];

Thaccl = (diff(Thvel));
Rhaccl = (diff(Rhvel));
pAcl = [Thaccl,Rhaccl];

Spd = [Spd;nan];
pAcl = [pAcl;nan,nan];
end