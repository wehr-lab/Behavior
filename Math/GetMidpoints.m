function [mdpt] = GetMidpoints(XYpt1,XYpt2)
x1 = XYpt1(:,1); x2 = XYpt2(:,1);
y1 = XYpt1(:,2); y2 = XYpt2(:,2);
mdpt = [(x1+x2)/2,(y1+y2)/2];
end