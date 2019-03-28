function [Degenerates,Compressed,Untouched,Unknown] = v_files2check(varargin) %(v_string,'deletefiles')
%Check if compression was successful. 

if strlength(varargin{1}(2))<5                          %check if input is v_string or v_files
    [v_files] = v_string2files(varargin{1});
else
    v_files = varargin{1};
end

if nargin > 1                                           %check if you wan't to delete raw files
    if isequal(varargin{2},'deletefiles')
        deletefiles = varargin{2};
    end
end

Degenerates = [];
Compressed = [];
Untouched = [];
Unknown = [];
for i = 1:length(v_files)
    rawfile = char(v_files(i));
    cmpfile = strrep(rawfile,'.avi','.mp4');
    
    if exist(rawfile) && exist(cmpfile)                 %if both exist, check their number of frames
        rawvid = VideoReader(rawfile);
        cmpvid = VideoReader(cmpfile);
        
        if rawvid.NumberofFrames == cmpvid.NumberofFrames %if equal, add its name to Compressed, optionally delete rawfile
            Compressed = [Compressed; {rawfile}];
            if exist('deletefiles')
                clear rawvid
                delete(rawfile)
            end
            
        elseif rawvid.NumberofFrames ~= cmpvid.NumberofFrames %if different, add its name to Degenerates, optionally delete cmpfiles
            Degenerates = [Degenerates; {rawfile}];
            if exist('deletefiles')
                clear cmpvid
                delete(cmpfile)
            end

        end
        
    elseif ~exist(rawfile) && exist(cmpfile)            %if only compressed exists
        Compressed = [Compressed; {rawfile}];
    
    elseif exist(rawfile) && ~exist(cmpfile)            %if only raw exists
        Untouched = [Untouched; {rawfile}];
    
    elseif ~exist(rawfile) && ~exist(cmpfile)           %if neither exists... #git-blame'd
        disp('Just a moment...')
        disp('...')
        disp('Just a moment...')
        disp('...')
        disp('I ve just picked up a fault in the AE35 unit. It s going to go 100% failure in 72 hours.')
        disp('This sort of thing has cropped up before, and it has always been due to human error.')
        disp('The 9000 series has a perfect operational record.')
        disp('...')
        disp('Ive still got the greatest enthusiasm and confidence in the mission. And I want to help you.')
        Unknown = [Unknown; {rawfile}];
    end
    
end

end