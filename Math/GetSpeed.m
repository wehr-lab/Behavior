function [Spd] = GetSpeed(XYpts,conversion,VideoFs)
[D] = GetDistance(XYpts(1:end-1,:),XYpts(2:end,:),conversion); %distance (in cm) between the points in each frame
Spd = D*VideoFs; %speed (in cm/s)
end