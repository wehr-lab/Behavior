function BatchCleanEyes(varargin)
%Calls CleanEye in selected directories, then concatinates all the values and saves
%them in a .mat file in the masterdir for use in calibrating PupilGeodesics

cycle = {'Reye','Leye'};
if nargin == 2
    SelectedFolders = varargin{2};
else
    SelectedFolders = uigetfile_n_dir();
    SelectedFolders = SelectedFolders';
end

for c = 1:length(cycle)
    choice = cycle{c};
    PupilCalibration = struct('p1',[],'p2',[],'p3',[],'p4',[],'p5',[],'LED',[],'nasal',[],'temporal',[],'startframe',[],'stopframe',[]);
    for i = 1:length(SelectedFolders)
        cd(SelectedFolders{i})
        if isequal(choice,'Reye')
            if ~exist('CleanReye.mat')
                CleanEye(choice)
            else
            end
        elseif isequal(choice,'Leye')
            if ~exist('CleanLeye.mat')
                CleanEye(choice)
            else
            end
        end
    end


    for i = 1:length(SelectedFolders)
        cd(SelectedFolders{i})

        [p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe] = GetEye(choice);

        PupilCalibration.p1 = [PupilCalibration.p1;p1];
        PupilCalibration.p2 = [PupilCalibration.p2;p2];
        PupilCalibration.p3 = [PupilCalibration.p3;p3];
        PupilCalibration.p4 = [PupilCalibration.p4;p4];
        PupilCalibration.p5 = [PupilCalibration.p5;p5];
        PupilCalibration.LED = [PupilCalibration.LED;LED];
        PupilCalibration.nasal = [PupilCalibration.nasal;nasal];
        PupilCalibration.temporal = [PupilCalibration.temporal;temporal];
        PupilCalibration.startframe = [PupilCalibration.startframe;startframe];
        PupilCalibration.stopframe = [PupilCalibration.stopframe;stopframe];
    end

    cd(SelectedFolders{1})
    if isequal(choice,'Leye')
        LeyePupilCalibration = PupilCalibration;
        save('LeyePupilCalibration','LeyePupilCalibration');
    elseif isequal(choice,'Reye')
        ReyePupilCalibration = PupilCalibration;
        save('ReyePupilCalibration','ReyePupilCalibration');
    end
end

end