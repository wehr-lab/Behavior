function [LeyeDuctions,ReyeDuctions] = PupilDuctions()
%Loads cyclotorsion and geodesics, then combines them to create the
%'complete' duction matrix for each eye (LeyeDuctions and ReyeDuctions)

LeyeDuctions = []; ReyeDuctions = []; %[theta,centralangle,cyclotorsion]

%%%%%%     Leye     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load('LeyeCyclotorsion.mat');
        Cyc = LeyeCyclotorsion.Cyc;
    load('LeyeGeodesics.mat');
        pup = LeyeGeodesics.pup;
        
    for i = 1:length(pup)
        [TH,PHI] = cart2sph(pup(i,1),pup(i,2),pup(i,3));
        LeyeDuctions = [LeyeDuctions;[TH,PHI,Cyc(i)]];
    end
    
%%%%%%     Reye     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load('ReyeCyclotorsion.mat');
        Cyc = LeyeCyclotorsion.Cyc;
    load('ReyeGeodesics.mat');
        pup = ReyeGeodesics.pup;
        
    for i = 1:length(pup)
        [TH,PHI] = cart2sph(pup(i,1),pup(i,2),pup(i,3));
        ReyeDuctions = [ReyeDuctions;[TH,PHI,Cyc(i)]];
    end
    
end