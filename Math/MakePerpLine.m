function [xLine,yLine] = MakePerpLine(point,slope,LineLength)
% point - vector [x,y]
% slope - slope of the line
x = point(1);
y = point(2);
slope = -1/slope;
xLine = x-LineLength:x+LineLength;
yLine = slope*(xLine-x) + y;
% plot(x,y,'ro')
% plot(xLine,yLine,'b')
end