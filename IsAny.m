function [proceed] = IsAny(choice,string)
    proceed = 0;
    for i = 1:length(choice)
        if isequal(choice{i},{string})
            proceed = 1;
        elseif isequal(choice{i},string) %safety measure if length(choice) = 1
            proceed = 1;
        end
    end
end