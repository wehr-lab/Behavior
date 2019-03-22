function BatchProcessCams(varargin)
choice = varargin{1}; %'eyes' and/or 'ears'
if nargin == 2
    SelectedFolders = varargin{2};
else
    SelectedFolders = uigetfile_n_dir(pwd);
    SelectedFolders = SelectedFolders';
end

for i = 1:length(SelectedFolders)
    cd(SelectedFolders{i})
    ProcessCams(choice);
end


end