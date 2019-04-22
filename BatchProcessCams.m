function BatchProcessCams(varargin)
%Calls ProcessCams in selected directories
%varargin = 'eyes' and/or 'ears' and/or 'no_trigs'

SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

for i = 1:length(SelectedFolders)
    cd(SelectedFolders{i})
    ProcessCams(varargin{1:end});
end


end