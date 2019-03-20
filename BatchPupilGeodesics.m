function BatchPupilGeodesics(varargin)
LeyeRadius = varargin{1};
ReyeRadius = varargin{2};

SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

for i = 1:length(SelectedFolders)
    cd(SelectedFolders{i})
    PupilGeodesics('Leye',LeyeRadius);
    PupilGeodesics('Reye',ReyeRadius);

end

close all;

end