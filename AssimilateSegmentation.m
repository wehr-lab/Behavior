function [vids,units,chans] = AssimilateSegmentation()
load('Segmentation.mat');
load('AssimilationWO.mat');
%% declare videos & calculate ranges
test = fields(Seg);
for i = 1:length(test)
    event = test{i};
    if ~isempty(Seg.(event))
        
        % Vids:
        if ~isempty(vids)
            vids(1).(event) = Seg.(event);
            if ~isequal(length(vids),1) %if more than one camera
                vids(2).(event) = ThisToThat('Sky',Seg.(event),'Head'); close;
                vids(3).(event) = ThisToThat('Sky',Seg.(event),'Lear'); close;
                vids(4).(event) = ThisToThat('Sky',Seg.(event),'Rear'); close;
            end
        end
        
        % Units:
        if ~isempty(units)
            units(1).(event) = ThisToThat('Sky',Seg.(event),'OE'); close;
            units(1).(event) = (units(1).(event)) / units(1).sampleRate;
            for i = 2:length(chans)
                chans(i).(event) = chans(1).(event);
            end
        end
        
        % Chans:
        if ~isempty(chans)
            chans(1).(event) = ThisToThat('Sky',Seg.(event),'OE'); close;
            for i = 2:length(chans)
                chans(i).(event) = chans(1).(event);
            end
        end
        
    end
end
end