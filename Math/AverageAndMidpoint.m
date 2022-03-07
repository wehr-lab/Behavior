function [outline] = AverageAndMidpoint(pt1,pt2)
pt1 = mean(pt1);
pt2 = mean(pt2);
mdpt = GetMidpoints(pt1,pt2);
outline = [pt1;mdpt;pt2];
end