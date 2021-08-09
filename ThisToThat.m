function [OutputIndex] = ThisToThat(varargin) %Run in either the bonsai folder, or it's OE folder
    InputDataStream = varargin{1};
    InputEventIndex = varargin{2};
    OutputDataStream = varargin{3};
    
%% %%%%%%%%%%%%% load Bonsai/OE info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    currentdir = pwd; %remember where we started
    test = dir('*.continuous');
    if length(test) < 1 %that means we're in the bonsai folder
        behaviorfile = dir('Beh*.mat'); load(behaviorfile.name); %so load the behavior file
        ephysfolder=Sky.ephysfolder;
        if ismac ephysfolder=macifypath(ephysfolder);end
        cd(ephysfolder); %then go to the ephys folder
        [~,~,~,~,Events,~] = LoadExperiment(); %and get Events
        
    else %we're in the ephys folder
        [~,~,~,~,Events,~] = LoadExperiment(); %so get Events
        cd .. %then back out to the bonsai folder
        behaviorfile = dir('Beh*.mat'); load(behaviorfile.name); %and load the behavior file
    end
    cd(currentdir); %cd back to whichever directory we started in
    
%% %%%%%%%%%%%%% get position(s) between trigs %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(InputDataStream,'OE')
        if ~isnan(Events(1).soundcard_trigger_timestamp_sec) %default to using the SCTs
            Trig1_in = (Events(1).soundcard_trigger_timestamp_sec)*30000;
            Trig2_in = (Events(end).soundcard_trigger_timestamp_sec)*30000;
            [TrigRatio] = GetTrigRatio(InputEventIndex,Trig1_in,Trig2_in);
        else %but use the events if SCTs not recorded (To do: add warning flag in this case)
            Trig1_in = (Events(1).message_timestamp_samples);
            Trig2_in = (Events(end).message_timestamp_samples);
            [TrigRatio] = GetTrigRatio(InputEventIndex,Trig1_in,Trig2_in);
        end
        
    elseif isequal(InputDataStream,'Sky')
        InputEventTime = Sky.times(InputEventIndex);
        Trig1_inTime = Sky.TTtimes(1);
        Trig2_inTime = Sky.TTtimes(end);
        [TrigRatio] = GetTrigRatio(InputEventTime,Trig1_inTime,Trig2_inTime);
        
    else %Headcam data
        [SpecificStructure] = String2Struct(InputDataStream);
        InputEventTime = SpecificStructure.times(InputEventIndex);
        Trig1_inTime = Sky.TTtimes(1);
        Trig2_inTime = Sky.TTtimes(end);
        [TrigRatio] = GetTrigRatio(InputEventTime,Trig1_inTime,Trig2_inTime);
    end

%% %%%%%% find equivalent sample between trigs, add offset by trig1 %%%%%%%
    if isequal(OutputDataStream,'OE')
        if ~isnan(Events(1).soundcard_trigger_timestamp_sec) %default to using the SCTs
            Trig1_out = (Events(1).soundcard_trigger_timestamp_sec)*30000;
            Trig2_out = (Events(end).soundcard_trigger_timestamp_sec)*30000;
            [OutputIndex] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out);
        else %but use the events if SCTs not recorded (To do: add warning flag in this case)
            Trig1_out = (Events(1).message_timestamp_samples);
            Trig2_out = (Events(end).message_timestamp_samples);
            [OutputIndex] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out);
        end
        
    elseif isequal(OutputDataStream,'Sky')
        Trig1_out = Sky.TTtimes(1);
        Trig2_out = Sky.TTtimes(end);
        [IdealTime] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out);
%         [c, OutputIndex] = min(abs(Sky.times-IdealTime));
        [OutputIndex] = Time2Index(IdealTime, Sky);
        
    else %Headcam data
        [SpecificStructure] = String2Struct(OutputDataStream);
        Trig1_out = SpecificStructure.TTtimes(1);
        Trig2_out = SpecificStructure.TTtimes(end);
        [IdealTime] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out);
        [c, OutputIndex] = min(abs(SpecificStructure.times-IdealTime));
        OutputIndex = OutputIndex*2;
    end

end

%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TrigRatio] = GetTrigRatio(InputEventIndex,Trig1_in,Trig2_in)
    TSBTinput = (Trig2_in)-(Trig1_in);                              %TotalSamplesBetweenTrigs
        for i = 1:length(InputEventIndex)
            TrigRatio(i) = (InputEventIndex(i)-Trig1_in(1))/(TSBTinput);
        end
end
function [OutputIndex] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out)
    TSBToutput = (Trig2_out)-(Trig1_out);                              %TotalSamplesBetweenTrigs
        for i = 1:length(TrigRatio)
            OutputIndex(i) = (TSBToutput*TrigRatio(i))+(Trig1_out);
        end
end
function [SpecificStructure] = String2Struct(InputDataStream)
%%%%%%%%%%%%%%% load Bonsai info %%%%%%%%%%%%%%%
    currentdir = pwd; %remember where we started
    test = dir('*.continuous');
    if length(test) < 1 %that means we're in the bonsai folder
        behaviorfile = dir('Beh*.mat'); load(behaviorfile.name); %so load the behavior file
    else %we're in the ephys folder
        cd .. %so back out to the bonsai folder
        behaviorfile = dir('Beh*.mat'); load(behaviorfile.name); %and load the behavior file
    end
    cd(currentdir); %cd back to whichever directory we started in
    
    if isequal(InputDataStream,'Leye')
        SpecificStructure = Leye;
    elseif isequal(InputDataStream,'Reye')
        SpecificStructure = Reye;
    elseif isequal(InputDataStream,'Lear')
        SpecificStructure = Lear;
    elseif isequal(InputDataStream,'Rear')
        SpecificStructure = Rear;
    elseif isequal(InputDataStream,'Head')
        SpecificStructure = Head;
    elseif isequal(InputDataStream,'Forw')
        SpecificStructure = Forw;
    end
end
function [OutputIndex] = Time2Index(IdealTime, Sky)
    for i = 1:length(IdealTime)
        [c, OutputIndex(i)] = min(abs(Sky.times-IdealTime(i)));
    end
end