function [mID,mIDstr] = GetMouseID(Sky)
mID = strsplit(Sky.vid.name,'_'); 
mID = mID{2}; mID = strsplit(mID,'-'); 
mIDstr = mID{2}; 
mID = str2num(mIDstr);
end