function BatchPupilGeodesics(varargin)

LeyeRadius = varargin{1};
ReyeRadius = varargin{2};

if nargin == 3
    SelectedFolders = varargin{3};
else
    SelectedFolders = uigetfile_n_dir(pwd);
    SelectedFolders = SelectedFolders';
end

for i = 1:length(SelectedFolders)
    cd(SelectedFolders{i})
    PupilGeodesics('Leye',LeyeRadius);
    PupilGeodesics('Reye',ReyeRadius);
end

close all;

end