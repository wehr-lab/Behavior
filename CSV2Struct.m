function [S,T] = CSV2Struct(filename)
T = readtable(filename,'Delimiter',',');
S = table2struct(T);
end