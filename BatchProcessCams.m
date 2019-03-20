function BatchProcessCams(varargin)
choice = varargin; %'eyes' and/or 'ears'
SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

for i = 1:length(SelectedFolders)
    cd(SelectedFolders{i})
    ProcessCams(choice);
end


end