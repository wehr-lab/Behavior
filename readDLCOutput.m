function [outputstructure] = readDLCOutput(inputstructure)
    titles = strsplit(inputstructure.raw{2,1},',');
    titles = titles(2:end);
    numberofpoints = (length(titles))/3;
    u = unique(titles);
    for i = 1:numberofpoints
        columnIdx = [];
        for ii = 1:length(titles)
            columnIdx = [columnIdx;isequal(u(i),{titles{ii}})];
        end
        columns{1,i} = u(i);
        columns{2,i} = find(columnIdx);
    end
    inputstructure.length = length(inputstructure.raw)-3;
    for i = 1:numberofpoints
        name = string(columns{1,i});
        inputstructure.(name) = dlmread(inputstructure.csv.name,',',[3,columns{2,i}(1),inputstructure.length,columns{2,i}(end)]);
    end
    inputstructure.numberofpoints = numberofpoints;
    outputstructure = inputstructure;
end