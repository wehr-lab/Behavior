function [pt2] = PointSlope4Yvalue(pt1,slope,x)
x1 = pt1(:,1); y1 = pt1(:,2);
y = ((x-x1)*slope)+y1;
pt2 = [x,y];
end