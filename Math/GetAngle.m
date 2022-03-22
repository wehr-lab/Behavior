function [Angle] = GetAngle(centerXYpt,refXYpt,measureXYpt)
%First, cut out the DLC probability values from the points if present:
    centerXYpt = centerXYpt(:,1:2);
    refXYpt = refXYpt(:,1:2);
    measureXYpt = measureXYpt(:,1:2);
    
%Second, match the length of the center/reference points to the input points if necessary:
    MaxMeasure = max([size(centerXYpt,1),size(refXYpt,1),size(measureXYpt,1)]);
    if ~isequal(size(centerXYpt,1),MaxMeasure)
        centerptX(1:MaxMeasure,:) = centerXYpt(1,1);
        centerptY(1:MaxMeasure,:) = centerXYpt(1,2);
        centerXYpt = [centerptX,centerptY];
    end
    if ~isequal(size(refXYpt,1),MaxMeasure)
        pt2X(1:MaxMeasure,:) = refXYpt(1,1);
        pt2Y(1:MaxMeasure,:) = refXYpt(1,2);
        refXYpt = [pt2X,pt2Y];
    end
    if ~isequal(size(measureXYpt,1),MaxMeasure)
        pt2X(1:MaxMeasure,:) = measureXYpt(1,1);
        pt2Y(1:MaxMeasure,:) = measureXYpt(1,2);
        measureXYpt = [pt2X,pt2Y];
    end

%Then do the actual calculation:
    n1 = (measureXYpt - centerXYpt) / normNaN(measureXYpt - centerXYpt);  %Normalized vector1
    n2 = (refXYpt - centerXYpt) / normNaN(refXYpt - centerXYpt); %Normalized vector2
    
    Angle = zeros(size(measureXYpt,1),1);
    for i = 1:MaxMeasure
        Angle(i,1) = atan2(normNaN(det([n2(i,:); n1(i,:)])), dot(n1(i,:), n2(i,:)));
    end

%Lastly, determine if the angle is to the right(1) or left(0)
    v1 = [n1,zeros(MaxMeasure,1)];
    v2 = [n2,zeros(MaxMeasure,1)];
    n = [0,0,1];
    a = zeros(size(measureXYpt,1),1);
    for i = 1:MaxMeasure
        a(i,1) = vecangle360(v1(i,:),v2(i,:),n);
    end
    polarity = sign(a)+1;
%and make the left angle values negative:
    negative = find(polarity==0);
    Angle(negative) = Angle(negative)*-1;
end

function [output] = normNaN(input)
Idx = ~isnan(input(:,1));
output = norm(input(Idx(:),:));
end