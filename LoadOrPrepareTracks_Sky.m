%load the behavior and assimilation file, then run this script
SkyDLCtype = 'madlc'; %'dlc' 'fdlc' or 'madlc'
pThresh = 0.90; %DLC probability threshold
SmoothValue = 75;
Skysavename = strcat('PreparedSky_',SkyDLCtype,'_p',num2str(pThresh*100),'_s',num2str(SmoothValue),'.mat');

try
    load(Skysavename);
catch
    SkyVideo = VideoReader(vids(1).file); SkySize = [SkyVideo.Width,SkyVideo.Height];
        [s1] = GetCamPtsY(Sky.(SkyDLCtype),SkySize); 
        [s1] = FitCircle(s1,SkyVideo,SkySize);
        [s1,rectN] = RelateSkyCam(s1,pThresh,SmoothValue);
    save(Skysavename,'s1','rectN')
end

%% Coordinate/DLC Functions:
function [newStruct] = GetCamPtsY(CamStruct,CamSize)
fields = fieldnames(CamStruct); C = struct2cell(CamStruct);
newStruct = struct(); newStruct.t = table();
test = strsplit(CamStruct.csv.name,'_'); test = test{1};
for i = 4:length(fields)
    if isequal(test,'Lear')
        flipped = flipYcoordinate(C{i,1}(:,1:3),CamSize,-90);
    elseif isequal(test,'Rear')
        flipped = flipYcoordinate(C{i,1}(:,1:3),CamSize,90);
    else
        flipped = flipYcoordinate(C{i,1}(:,1:3),CamSize);
    end
    newStruct.t = addvars(newStruct.t,flipped,'NewVariableNames', {fields{i}});
end
newStruct.size = CamSize;
end
function [newStruct] = GetCamPtsX(CamStruct,CamSize)
fields = fieldnames(CamStruct);
C = struct2cell(CamStruct);
newStruct = struct();
newStruct.t = table();
for i = 4:length(fields)
    flipped = flipXcoordinate(C{i,1}(:,1:3),CamSize);
    newStruct.t = addvars(newStruct.t,flipped,'NewVariableNames', {fields{i}});
end
newStruct.size = CamSize;
end
    function [cp,tl,tr,bl,br] = GetCenterAndCorners(VideoSize)
    cp = [VideoSize(1)/2,VideoSize(2)/2];
    tl = [0,VideoSize(2)];
    tr = [VideoSize(1),VideoSize(2)];
    bl = [0,0];
    br = [VideoSize(1),0];
    end
    function [outputxypts] = flipYcoordinate(varargin)
    xypts = varargin{1}; VideoSize = varargin{2};
    difference = xypts(:,2)-(ones(size(xypts(:,2)))*(VideoSize(2)/2));
    xypts(:,2) = xypts(:,2)+(-2*difference);
    if gt(size(varargin,2),2)
        %%%%%%move origin to center and rotate
        [cp,tl,tr,bl,br] = GetCenterAndCorners(VideoSize);
        xypts(:,1:2) = xypts(:,1:2) - cp;
        theta = varargin{3};
        R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
        xypts(:,1:2) = xypts(:,1:2)*R;
        if isequal(theta,90)
            [ncp,tl,tr,bl,br] = GetCenterAndCorners(fliplr(VideoSize));
            xypts(:,1:2) = xypts(:,1:2) + ncp;
        elseif isequal(theta,-90)
            [ncp,tl,tr,bl,br] = GetCenterAndCorners(fliplr(VideoSize));
            xypts(:,1:2) = xypts(:,1:2) + ncp;
        else
            error('Can only rotate by 90 and -90 at the moment...');
        end
    end
    outputxypts = xypts;
    end
    function [outputxypts] = flipXcoordinate(varargin)
    xypts = varargin{1}; VideoSize = varargin{2};
    difference = xypts(:,1)-(ones(size(xypts(:,1)))*(VideoSize(1)/2));
    xypts(:,1) = xypts(:,1)+(-2*difference);
    if gt(size(varargin,2),2)
        %%%%%%move origin to center and rotate
        [cp,tl,tr,bl,br] = GetCenterAndCorners(VideoSize);
        xypts(:,1:2) = xypts(:,1:2) - cp;
        theta = varargin{3};
        R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
        xypts(:,1:2) = xypts(:,1:2)*R;
        if isequal(theta,90)
            [ncp,tl,tr,bl,br] = GetCenterAndCorners(fliplr(VideoSize));
            xypts(:,1:2) = xypts(:,1:2) + ncp;
        elseif isequal(theta,-90)
            [ncp,tl,tr,bl,br] = GetCenterAndCorners(fliplr(VideoSize));
            xypts(:,1:2) = xypts(:,1:2) + ncp;
        else
            error('Can only rotate by 90 and -90 at the moment...');
        end
    end
    outputxypts = xypts;
end

function [s1,rect] = RelateSkyCam(s1,pThresh,SmoothValue)
cropW = s1.size(2); cropH = s1.size(2); %cp = [s1.size(1)/2,s1.size(2)/2];
cp = [s1.Circ.center(1),s1.size(2)/2];
[rect] = MakeCropBox(cp,cropW,cropH,s1.size);
cropRatio = cropW/cropH;

s1.Xt = 0; s1.Yt = 0; %origin (bottom-left)
s1.Xrange = [s1.Xt s1.Xt+cropW]; s1.Yrange = [s1.Yt s1.Yt+cropH];
s1.Yrange = fliplr(s1.Yrange); s1.Yt = s1.Yrange(2);

for i = 1:width(s1.t)
    CroppedXY = s1.t{:,i}(:,1:2)-((cp)+[-cropW/2,-cropH/2]);
    [resizedXY] = ResizeCoordinates(CroppedXY,[cropW,cropH],s1.Xrange,s1.Yrange);
    resizedXY = resizedXY + [s1.Xt,s1.Yt];
    
    %Identify GoodFrames:
    pValues = s1.t{:,i}(:,3);
    if isequal(i,3) || isequal(i,4) %cricket points only
%         M = movmean(pValues,20);
%         GoodFrames = M > pThresh; 
        GoodFrames = pValues > pThresh; 
    else
        GoodFrames = pValues > pThresh; 
    end
    x = find(GoodFrames);
    PoorFrames = ones(size(pValues)); PoorFrames(x) = 0;
    xq = find(PoorFrames);
    
    %Interpolate:
    vq1 = [];
    newpts = resizedXY;
    for k = 1:2 %X and Y
        v = resizedXY(:,k);
        v = v(x);
        try %sometime there are not good frames, which causes an error
            vq1(:,k) = interp1(x,v,xq);
            newpts(xq,k) = vq1(:,k);
        catch
        end
    end
%     figure; plot(resizedXY(:,1)); hold on; plot(resizedXY(:,2)); plot(newpts(:,1)); plot(newpts(:,2));
    resizedXY = newpts;
    
    %Smoothing:
    resizedXYsmthBig(:,1) = smooth(resizedXY(:,1),SmoothValue,'loess');
    resizedXYsmthBig(:,2) = smooth(resizedXY(:,2),SmoothValue,'loess');
% % % % %     figure; plot(resizedXY); hold on; plot(resizedXYsmthBig); title('Smoothed 300');hold on;   
    resizedXY = resizedXYsmthBig;
    
    newXYP = [resizedXY,s1.t{:,i}(:,3)];
    s1.t{:,i} = newXYP;
end

CroppedXY = s1.Circ.input-((cp)+[-cropW/2,-cropH/2]);
[resizedXY] = ResizeCoordinates(CroppedXY,[cropW,cropH],s1.Xrange,s1.Yrange);
resizedXY = resizedXY + [s1.Xt,s1.Yt];

[R,xcyc] = fit_circle_through_3_points(resizedXY);
s1.Circ.center = xcyc;
s1.Circ.radius = R;
s1.Circ.diameter = s1.Circ.radius*2;

s1.Circ.conversion = (24/(s1.Circ.diameter))*2.54; %24 in arena and 2.54cm/in
end
    function [rect] = MakeCropBox(cpt,Width,Height,SkySize)
xmin = cpt(:,1)-(Width/2);
ymin = cpt(:,2)+(Height/2);
[outputxypt] = flipYcoordinate([xmin,ymin],SkySize); %flips because it will be used to read the raw image
xmin = outputxypt(:,1);
ymin = outputxypt(:,2);
rect = [xmin ymin Width Height];
    end
    function [newpts] = ResizeCoordinates(pts,FrameSize,NRangex,NRangey)
NewSize = [abs(NRangex(2)-NRangex(1)),abs(NRangey(2)-NRangey(1))];
xpts = pts(:,1)'; ypts = pts(:,2)';

%clip values so the rescale is accurate:
[xpts] = clipValues(xpts,0,FrameSize(1));
[ypts] = clipValues(ypts,0,FrameSize(2));

Xscale = rescale([0,xpts,FrameSize(1)]);
Yscale = rescale([0,ypts,FrameSize(2)]);
X = Xscale((2:length(pts(:,1))+1))*NewSize(1);
Y = Yscale((2:length(pts(:,2))+1))*NewSize(2);
newpts = [X;Y]';
    end
    function [upts] = clipValues(upts,minimum,maximum)
max_idx = find(upts > maximum);
upts(max_idx) = maximum;
min_idx = find(upts < minimum);
upts(min_idx) = minimum;
    end
    
function [s1] = FitCircle(s1,SkyVideo,SkySize)
try
    test = dir('Circ*.mat');
    load(test(1).name);
    Circ.center = flipYcoordinate(Circ.center',SkySize);
    Circ.input = flipYcoordinate(Circ.input,SkySize);
catch
    FitCircleGUI(SkyVideo,SkySize);
    test = dir('Circ*.mat');
    load(test(1).name);
    Circ.center = flipYcoordinate(Circ.center',SkySize);
    Circ.input = flipYcoordinate(Circ.input,SkySize);
end
s1.Circ = Circ;
end