function [] = SegmentExp()
load('AssimilationWO.mat');
SkyVideo = VideoReader(vids(1).file);
[fig_handle, axes_handle, scroll_bar_handles, scroll_func] = videofig(SkyVideo.NumberOfFrames, @(frm) redraw(frm, SkyVideo));
%set(fig_handle,'Position',[337 151 1099 664]);
set(fig_handle,'Position',[0.1799    0.1778    0.8187    0.7867]);
[frame] = redraw(1, SkyVideo);
[fig] = SegmentationGUI();
set(fig,'Position',[36 452 241 354]);
uiwait(fig);
close(fig_handle);
[Seg] = SaveSegmentation();
    
pause(0.5);
disp('Segmentation successfully saved!')
end

%% Functions:
function [fig] = SegmentationGUI()
fig = uifigure('Name','SegmentationGUI','Position',[500,500,250,300]);
btn = uibutton(fig,'Text','Launch','Position',[10, 270, 100, 22],'ButtonPushedFcn', @(btn,event) SetLaunch()); 
btn2 = uibutton(fig,'Text','TetherHS','Position',[10, 240, 100, 22],'ButtonPushedFcn', @(btn2,event) SetTetherHS()); 
btn3 = uibutton(fig,'Text','Land','Position',[125, 220, 100, 22],'ButtonPushedFcn', @(btn3,event) SetLand()); 
btn4 = uibutton(fig,'Text','TetherHSpl','Position',[10, 200, 100, 22],'ButtonPushedFcn', @(btn4,event) SetTetherHSpl()); 
btn5 = uibutton(fig,'Text','Land2','Position',[10, 170, 100, 22],'ButtonPushedFcn', @(btn5,event) SetLand2()); 
btn6 = uibutton(fig,'Text','TerminalCap','Position',[125, 150, 100, 22],'ButtonPushedFcn', @(btn6,event) SetTerminalCap()); 
btn7 = uibutton(fig,'Text','TooTangled','Position',[125, 120, 100, 22],'ButtonPushedFcn', @(btn7,event) SetTooTangled()); 

btnEND = uibutton(fig,'Text','Finalize','Position',[10, 80, 100, 22],'ButtonPushedFcn', @(btnEND,event) FinalizeSegmentation()); 

function SetLaunch()
    global LaunchFrame
    LaunchFrame = getGlobalFrame;
end
function SetTetherHS()
    global TetherHS
    TetherHS = getGlobalFrame;
end
function SetLand()
    global Land
    Land = getGlobalFrame;
end
function SetTetherHSpl()
    global TetherHSpl
    TetherHSpl = getGlobalFrame;
end
function SetLand2()
    global Land2
    Land2 = getGlobalFrame;
end
function SetTerminalCap()
    global TerminalCap
    TerminalCap = getGlobalFrame;
end
function SetTooTangled()
    global TooTangled
    TooTangled = getGlobalFrame;
end

function FinalizeSegmentation()    
    close(fig)
end
end
function [frame] = redraw(frame, vidObj)
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
function r = getGlobalFrame
global Frame
r = Frame;
end
function AssimilationAnswer = AssimilationQuestion
answer = questdlg('Would you like to Assimilate Segmentation?', ...
	'Assimilation Menu', ...
	'Yes','No','No');
% Handle response
switch answer
    case 'Yes'
        disp([answer ' coming right up.'])
        AssimilationAnswer = 1;
    case 'No'
        disp([answer ' will not be assimilated'])
        AssimilationAnswer = 0;
end

end
function [Seg] = SaveSegmentation()
    global LaunchFrame
    global TetherHS
    global Land
    global TetherHSpl
    global Land2
    global TerminalCap
    global TooTangled
    
    Seg.LaunchFrame = LaunchFrame;
    Seg.TetherHS = TetherHS;
    Seg.Land = Land;
    Seg.TetherHSpl = TetherHSpl;
    Seg.Land2 = Land2;
    Seg.TerminalCap = TerminalCap;
    Seg.TooTangled = TooTangled;
    
    save('Segmentation.mat','Seg')
    clearvars -global
end