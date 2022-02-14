function [] = SegmentExp(varargin)
%Input1: the file name of the video
%Input2 (Optional): 1x4 position value for the videofigure. 
%Input2 (Optional): or just input any number/string and it will put the videofigure on the main screen.

global Seg
global Frame
global laserCB

Seg.LaunchFrame = [];
Seg.TetherHS = [];
Seg.Land = [];
Seg.TetherHSpl =[];
Seg.Land2 = [];
Seg.TerminalCap = [];
Seg.IntermediateCap = [];
Seg.TooTangled = [];
Seg.TangleON = [];
Seg.TangleOFF = [];
Seg.CricketOUT = [];
Seg.CricketIN = [];
        
Frame = 1;

vidFN = varargin{1}
SkyVideo = VideoReader(vidFN);

try
    fig_handle = videofig(SkyVideo.NumFrames, @(frm) redraw(frm, SkyVideo));
catch
    fig_handle = videofig(SkyVideo.NumberOfFrames, @(frm) redraw(frm, SkyVideo));
end

if isequal(length(varargin),1) %places video figure on top screen (default)(good for rig4)
    set(fig_handle,'Position',[0.029  1.084  0.85 0.85]); 
elseif isequal(size(varargin{2}),[1,4])%places video figure where you specify, with a 1x4 double
    set(fig_handle,'Position',varargin{2});
else %if you just input any number or string, it will place the video figure on main screen (good across rigs)
    set(fig_handle,'Position',[0.1620  .0778  0.6328 0.8704]); 
end

redraw(Frame, SkyVideo);
fig = SegmentationGUI();
set(fig,'Position',[36 452 250 300]);
uiwait(fig);
close(fig_handle);

end

% Functions:
function [fig] = SegmentationGUI()
global laserCB
fig = uifigure('Name','SegmentationGUI','Position',[40,450,250,300]);

btn(1) = uibutton(fig,'Text','Launch','Position',[10, 270, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(1),'BackgroundColor',[.8 .8 .8]);
btn(2) = uibutton(fig,'Text','TetherHS','Position',[10, 240, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(2),'BackgroundColor',[.8 .8 .8]);
btn(3) = uibutton(fig,'Text','Land','Position',[125, 220, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(3));
btn(4) = uibutton(fig,'Text','TetherHSpl','Position',[10, 200, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(4),'BackgroundColor',[.8 .8 .8]);
btn(5) = uibutton(fig,'Text','Land2','Position',[10, 170, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(5),'BackgroundColor',[.8 .8 .8]);
btn(6) = uibutton(fig,'Text','TerminalCap','Position',[125, 150, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(6));
btn(7) = uibutton(fig,'Text','TooTangled','Position',[10, 120, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(7),'BackgroundColor',[.8 .8 .8]);
btn(8) = uibutton(fig,'Text','Tangle ON','Position',[125, 90, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(8));
btn(9) = uibutton(fig,'Text','Tangle OFF','Position',[125, 60, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(9));
btn(10) = uibutton(fig,'Text','Cricket OUT','Position',[10, 90, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(10));
btn(11) = uibutton(fig,'Text','Cricket IN','Position',[10, 60, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(11));
laserCB = uicheckbox(fig,'Text','LaserCK','position',[120,20,70,22]);
btn(12) = uibutton(fig,'Text','Finalize','Position',[10, 20, 100, 22],'ButtonPushedFcn', @(btn,event) setInfo(12,fig),'BackgroundColor','yellow');
btn(13) = uibutton(fig,'Text','Clear','Position',[195, 20, 55, 22],'ButtonPushedFcn', @(btn,event) setInfo(13),'BackgroundColor',[.8 .5 .5]);
end

function setInfo(butNum,fig)
global Seg
global Frame
global laserCB

switch butNum
    case 1
        Seg.LaunchFrame = Frame;
    case 2
        Seg.TetherHS = Frame;
    case 3
        Seg.Land = Frame;
    case 4
        Seg.TetherHSpl =Frame;
    case 5
        Seg.Land2 = Frame;
    case 6
        if isempty(Seg.TerminalCap)
            Seg.TerminalCap = Frame;
        else
            Seg.IntermediateCap = [Seg.IntermediateCap Seg.TerminalCap];
            Seg.TerminalCap = Frame;
        end
    case 7
        Seg.TooTangled = Frame;
    case 8
        Seg.TangleON = Frame;
    case 9
        Seg.TangleOFF = Frame;
    case 10
        Seg.CricketOUT = Frame;
    case 11
        Seg.CricketIN = Frame;
    case 12
        if get(laserCB,'value')
            [Seg.LaserOn, Seg.LaserOff] = testSenseLaser(vidFN);
        elseif exist('LaserTiming','file')
            load LaserTiming LaserOn LaserOff
            Seg.LaserOn = LaserOn;
            Seg.LaserOff = LaserOff;
        else
            Seg.LaserOn = [];
            Seg.LaserOff =[];
        end
        save('Segmentation.mat','Seg')
        pause(0.5);
        disp('Segmentation successfully saved!')
        clearvars -global
        close(fig)
    case 13
        Seg.LaunchFrame = [];
        Seg.TetherHS = [];
        Seg.Land = [];
        Seg.TetherHSpl =[];
        Seg.Land2 = [];
        Seg.TerminalCap = [];
        Seg.IntermediateCap = [];
        Seg.TooTangled = [];
        Seg.TangleON = [];
        Seg.TangleOFF = [];
        Seg.CricketOUT = [];
        Seg.CricketIN = [];
        set(laserCB,'value',0);
end
end

function [frame] = redraw(frame, vidObj)
global Frame
Frame = frame;

% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object
% Read frame
f = vidObj.read(frame);

% Get edge
% f2 = edge(rgb2gray(f), 'canny');
% Overlay edge on original image
% f3 = bsxfun(@plus, f,  uint8(255*f2));
% Display
% image(f3); axis image off
image(f); axis image off
end
