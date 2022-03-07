function [Spd,Vel,Acl] = GetSpdVelAcl(XYpts,conversion,VideoFs)
[Spd] = GetSpeed(XYpts,conversion,VideoFs);

Xvel = (diff(XYpts(:,1))*conversion)*VideoFs;
Yvel = (diff(XYpts(:,2))*conversion)*VideoFs;
Vel = [Xvel,Yvel];

Xaccl = (diff(Xvel));
Yaccl = (diff(Yvel)); 
Acl = [Xaccl,Yaccl];

%append nans at beginnings:
Spd = [nan;Spd];
Vel = [nan,nan;Vel];
Acl = [nan,nan;nan,nan;Acl];
end