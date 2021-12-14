function Struct2CSV(structures,filename)
T = struct2table(structures);
writetable(T,filename)
end