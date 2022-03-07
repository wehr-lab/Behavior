function [Ang,aVel,aAcl] = GetAngVelAcl(centerXYpt,refXYpt,measureXYpt,VideoFs)
%First, calculate the angles:
    [Ang] = GetAngle(centerXYpt,refXYpt,measureXYpt);

%Next, calculate angular velocity (the change in radians/second) (1/s)
    aVel = nan(size(Ang));
    aVel(2:end) = diff(Ang);
    CompassJumps = gt(abs(aVel),pi); %detect cases where the change in angle appears to be greater than half a rotation
    aVel(CompassJumps) = (2*pi)-abs(aVel(CompassJumps)); %correct these cases to the smaller alternative angle (ex: +179 to -179 should be 2, not -358)
    aVel = aVel*VideoFs;

%Lastly, calculate angular acceleration (the change in the change in radians/second) (1/s*s)
    aAcl = nan(size(aVel));
    aAcl(2:end) = diff(aVel);
    aAcl = aAcl*VideoFs;
end