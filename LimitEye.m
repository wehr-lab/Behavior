function [p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe,newlength] = LimitEye(p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe)
    newlength = stopframe-startframe;
    for i = 1:newlength
        p1(i,:) = p1((startframe-1)+i,:);
        p2(i,:) = p2((startframe-1)+i,:);
        p3(i,:) = p3((startframe-1)+i,:);
        p4(i,:) = p4((startframe-1)+i,:);
        p5(i,:) = p5((startframe-1)+i,:);
        LED(i,:) = LED((startframe-1)+i,:);
        nasal(i,:) = nasal((startframe-1)+i,:);
        temporal(i,:) = temporal((startframe-1)+i,:);
    end
end