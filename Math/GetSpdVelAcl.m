function [Spd,Vel,Acl] = GetSpdVelAcl(XYpts,conversion,VideoFs)
[Spd] = GetSpeed(XYpts,conversion,VideoFs);

Xvel = (diff(XYpts(:,1))*conversion)*VideoFs;
Yvel = (diff(XYpts(:,2))*conversion)*VideoFs;
Vel = [Xvel,Yvel];

Xaccl = (diff(Xvel));
Yaccl = (diff(Yvel)); 
Acl = [Xaccl,Yaccl];

%append nans at end:
Spd = [Spd;nan]; %Spd = [nan;Spd];
Vel = [Vel;nan,nan]; %Vel = [nan,nan;Vel];
Acl = [Acl;nan,nan;nan,nan]; %Acl = [nan,nan;nan,nan;Acl];
end