function [output,outputX] = AlignedResampling(input,Fs,nFs)
p = nFs;
q = Fs;
output = resample(input,p,q);
outputX = linspace(1,length(input),length(output));
end