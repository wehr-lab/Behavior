function [pt2] = PointSlope4Xvalue(pt1,slope,y)
x1 = pt1(:,1); y1 = pt1(:,2);
x = ((y-y1)/slope)+x1;
pt2 = [x,y];
end