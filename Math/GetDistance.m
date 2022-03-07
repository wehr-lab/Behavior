function [D] = GetDistance(varargin)
XYpt1 = varargin{1}; XYpt2 = varargin{2};
x1 = XYpt1(:,1); x2 = XYpt2(:,1);
y1 = XYpt1(:,2); y2 = XYpt2(:,2);
D = sqrt( ((x2-x1).^2) + ((y2-y1).^2)) ;
if isequal(length(varargin),3)
    conversion = varargin{3};
    D = D*conversion;
end
end