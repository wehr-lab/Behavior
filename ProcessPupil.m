function [CamStruct] = ProcessPupil(CamStruct,DLCProbabilityThreshold)
px = zeros(length(CamStruct.dlc.point1),length(fields(CamStruct.dlc))-3); 
py = px; probability = px;
for i = 4:length(fields(CamStruct.dlc))
    str = strcat('point',num2str(i-3));
    px(:,i-3) = CamStruct.dlc.(str)(:,1);
    py(:,i-3) = CamStruct.dlc.(str)(:,2);
    probability(:,i-3) = CamStruct.dlc.(str)(:,3);
end

MajorDiameter = nan(length(px),1); 
MinorDiameter = MajorDiameter; Eccentricity = MinorDiameter; Indicatrix = MajorDiameter;

for i = 1:length(px) %For each frame
goodness = find(gt(probability(i,:),DLCProbabilityThreshold)); %Find Number of pts above DLCProbabilityThreshold
if ge(length(goodness),5) %If >= 5 good points, try to fit ellipse
    try
        ellipse_t = fit_ellipse(px(i,goodness),py(i,goodness));
        MajorDiameter(i) = ellipse_t.long_axis;
        if gt(MajorDiameter(i),125) %discard values that are inconcievably large
            MajorDiameter(i) = nan;
        else
            MinorDiameter(i) = ellipse_t.short_axis;
            [Eccentricity(i)] = CalculateEccentricity(ellipse_t.a,ellipse_t.b);
            Indicatrix(i) = ellipse_t.short_axis/ellipse_t.long_axis;
        end
    end

end
end

%Package the values back into the camerastructure for output:
CamStruct.PupilDiameter = MajorDiameter;
CamStruct.PupilMinor = MinorDiameter;
CamStruct.Eccentricity = Eccentricity;
CamStruct.Indicatrix = Indicatrix;
end

function [e] = CalculateEccentricity(a,b)
c = real(sqrt((a*a)-(b*b)));
e = c/a;
end