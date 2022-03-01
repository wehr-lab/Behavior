function djmaus_saveJSONfile(data, jsonFileName)
% saves the values in the structure 'data' to a file in JSON format.
%
% Example:
%     data.name = 'chair';
%     data.color = 'pink';
%     data.metrics.height = 0.3;
%     data.metrics.width = 1.3;
%     saveJSONfile(data, 'out.json');
%
% Output 'out.json':
% {
% 	"name" : "chair",
% 	"color" : "pink",
% 	"metrics" : {
% 		"height" : 0.3,
% 		"width" : 1.3
% 		}
% 	}
%
    fid = fopen(jsonFileName,'w');
    %fid=1;
    writeElement(fid, data,'');
    fprintf(fid,'\n');
    fclose(fid);
end
% function buildJSON(fid,data)
%     namesOfFields = fieldnames(data);
%     numFields = length(namesOfFields);
%     
%     if isstruct(
%     fprintf(fid,'{ "%s" : [\n ',rootElementName);
%     for m = 1:length(data) - 1
%        fprintf(fid,'{  \n ');
%        writeSingleGene(fid,numFields, namesOfFields,dataname,data,m);
%        fprintf(fid,'},\n');
%     end
%     m= m+1;
%     fprintf(fid,'{  \n ');
%     writeSingleGene(fid, numFields, namesOfFields,dataname,data,m);
%     fprintf(fid,' }\n]\n');
%     
%    
%     end
function writeElement(fid, data,tabs)
    namesOfFields = fieldnames(data);
    numFields = length(namesOfFields);
    tabs = sprintf('%s\t',tabs);
    fprintf(fid,'{\n%s',tabs);
   
    for i = 1:numFields - 1
        currentField = namesOfFields{i};
        currentElementValue = eval(sprintf('data.%s',currentField));
        if ~isequal(currentField,'notes')
            writeSingleElement(fid, currentField,currentElementValue,tabs);
        else
            writeSingleElement(fid, currentField,currentElementValue,tabs);
        end
        fprintf(fid,',\n%s',tabs);
    end
    if isempty(i)
        i=1;
    else
      i=i+1;
    end
      
    
    currentField = namesOfFields{i};
    currentElementValue = eval(sprintf('data.%s',currentField));
    writeSingleElement(fid, currentField,currentElementValue,tabs);
    fprintf(fid,'\n%s}',tabs);
end
function writeSingleElement(fid, currentField,currentElementValue,tabs)
    
        % if this is an array and not a string then iterate on every
        % element, if this is a single element write it
        if length(currentElementValue) > 1 && ~ischar(currentElementValue)
            fprintf(fid,' "%s" : [\n%s',currentField,tabs);
            for m = 1:length(currentElementValue)-1
                writeElement(fid, currentElementValue(m),tabs);
                fprintf(fid,',\n%s',tabs);
            end
            if isempty(m)
                m=1;
            else
              m=m+1;
            end
            
            writeElement(fid, currentElementValue(m),tabs);
          
            fprintf(fid,'\n%s]\n%s',tabs,tabs);
        elseif isstruct(currentElementValue)
            fprintf(fid,'"%s" : ',currentField);
            writeElement(fid, currentElementValue,tabs);
        elseif isnumeric(currentElementValue)
            fprintf(fid,'"%s" : %g' , currentField,currentElementValue);
        elseif isempty(currentElementValue)
            fprintf(fid,'"%s" : null' , currentField,currentElementValue);
        else %ischar or something else ...
            fprintf(fid,'"%s" : "%s"' , currentField,currentElementValue);
        end
end
% function writeSingleGene(fid,numFields, namesOfFields,dataname,data,m)
% 
%     for i = 1:numFields - 1
%         field = namesOfFields{i};
%         stmp = sprintf('%s(m).%s',dataname,field);
%         fprintf(fid,'"%s" : "%s",\n' , field,eval(stmp));
%     end
%     i=i+1;
%     field = namesOfFields{i};
%     stmp = sprintf('%s(m).%s',dataname,field);
%     fprintf(fid,'"%s" : "%s"\n',field,eval(stmp));
%         
%         
% end

% Copyright (c) 2015, Lior Kirsch
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.