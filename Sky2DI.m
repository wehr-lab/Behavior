function [DIframe,relation] = Sky2DI(varargin) %varargin = Skyframe,InputVid,optionalDesiredRelation
    %Returns frame# of InputVid closest in time to input Skyframe#
    Skyframe = varargin{1};
    InputVid = varargin{2};
    
    temp = dir('Behavior_mouse*.mat');
    load(temp.name);
    
    if isequal(InputVid,'Leye')
        test = milliseconds(Leye.times - Sky.times(Skyframe));
        frame = find(test>0,1);
        if isempty(frame)
            frame = length(test);
        end
        timeaftertime = milliseconds(Leye.times(frame)-Sky.times(Skyframe));
        timebefortime = milliseconds(Leye.times(frame-1)-Sky.times(Skyframe));
    elseif isequal(InputVid,'Reye')
        test = milliseconds(Reye.times - Sky.times(Skyframe));
        frame = find(test>0,1);
        if isempty(frame)
            frame = length(test);
        end
        timeaftertime = milliseconds(Reye.times(frame)-Sky.times(Skyframe));
        timebefortime = milliseconds(Reye.times(frame-1)-Sky.times(Skyframe));
    elseif isequal(InputVid,'Lear')
        test = milliseconds(Lear.times - Sky.times(Skyframe));
        frame = find(test>0,1);
        if isempty(frame)
            frame = length(test);
        end
        timeaftertime = milliseconds(Lear.times(frame)-Sky.times(Skyframe));
        timebefortime = milliseconds(Lear.times(frame-1)-Sky.times(Skyframe));
    elseif isequal(InputVid,'Rear')
        test = milliseconds(Rear.times - Sky.times(Skyframe));
        frame = find(test>0,1);
        if isempty(frame)
            frame = length(test);
        end
        timeaftertime = milliseconds(Rear.times(frame)-Sky.times(Skyframe));
        timebefortime = milliseconds(Rear.times(frame-1)-Sky.times(Skyframe));
    end
    
    if nargin == 2
        if abs(timeaftertime)<abs(timebefortime)
            closest = frame;
            DIframe = (closest*2)-1; %frameA
            relation = 'A';
        elseif abs(timebefortime)<abs(timeaftertime)
            closest = frame-1;
            DIframe = (closest*2); %frameB
            relation = 'B';
        end
    else
        if isequal(varargin{3},'A')
            closest = frame;
            DIframe = (closest*2)-1; %frameA
            relation = 'A';
        elseif isequal(varargin{3},'B')
            closest = frame-1;
            DIframe = (closest*2); %frameB
            relation = 'B';
        end
    end
end