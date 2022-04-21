function [] = Out2In(out)
%Takes in an out structure and returns all the fields as their own variables

names = fieldnames(out);
for i=1:length(names)
    eval([names{i} '=out.' names{i} ]);
end
clear names i;
vars = whos;
for k = 1:length(vars)
    assignin('caller', vars(k).name, eval(vars(k).name));
end
end