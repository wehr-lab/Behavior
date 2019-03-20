function [p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe] = GetEye(choice)
    FileOfInterest = strcat('Clean',choice,'*.mat');
    temp = dir(FileOfInterest);
    load(temp.name)
    temp = dir('Behavior*.mat');
    load(temp.name)
    stopframe = SkyTrack.skystop;
    [stopframe] = Sky2DI(stopframe,choice,'B');
    startframe = 1;
end