function BatchProcessCams(varargin)
%Calls ProcessCams in selected directories

choice = varargin{1}; %'eyes' and/or 'ears' and/or 'no_trigs'
SelectedFolders = uigetfile_n_dir(pwd);
SelectedFolders = SelectedFolders';

for i = 1:length(SelectedFolders)
    cd(SelectedFolders{i})
    ProcessCams(choice);
end


end