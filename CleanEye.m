function CleanEye(varargin) %varargin = 'Leye'or'Reye'
    %Manual removal of outliers. Returns LED-centered coordinates
    startframe = 1;
    choice = varargin{1};
    
    gocode = 0;
    while(gocode == 0)
        
    close all
    temp = dir('Behavior*.mat');
    load(temp.name);
    [stopframe] = Sky2DI(SkyTrack.skystop,choice,'B');

    if isequal(choice,'Leye')
        %Struct2matrices
        nasal = [LeyeTrack.nasal(1:stopframe,1),LeyeTrack.nasal(1:stopframe,2)];
        temporal = [LeyeTrack.temporal(1:stopframe,1),LeyeTrack.temporal(1:stopframe,2)];
        p1 = [LeyeTrack.pupil1(1:stopframe,1),LeyeTrack.pupil1(1:stopframe,2)];
        p2 = [LeyeTrack.pupil2(1:stopframe,1),LeyeTrack.pupil2(1:stopframe,2)];
        p3 = [LeyeTrack.pupil3(1:stopframe,1),LeyeTrack.pupil3(1:stopframe,2)];
        p4 = [LeyeTrack.pupil4(1:stopframe,1),LeyeTrack.pupil4(1:stopframe,2)];
        p5 = [LeyeTrack.pupil5(1:stopframe,1),LeyeTrack.pupil5(1:stopframe,2)];
        LED = [LeyeTrack.LED(1:stopframe,1),LeyeTrack.LED(1:stopframe,2)];
    elseif isequal(choice,'Reye')
        %Struct2matrices
        nasal = [ReyeTrack.nasal(1:stopframe,1),ReyeTrack.nasal(1:stopframe,2)];
        temporal = [ReyeTrack.temporal(1:stopframe,1),ReyeTrack.temporal(1:stopframe,2)];
        p1 = [ReyeTrack.pupil1(1:stopframe,1),ReyeTrack.pupil1(1:stopframe,2)];
        p2 = [ReyeTrack.pupil2(1:stopframe,1),ReyeTrack.pupil2(1:stopframe,2)];
        p3 = [ReyeTrack.pupil3(1:stopframe,1),ReyeTrack.pupil3(1:stopframe,2)];
        p4 = [ReyeTrack.pupil4(1:stopframe,1),ReyeTrack.pupil4(1:stopframe,2)];
        p5 = [ReyeTrack.pupil5(1:stopframe,1),ReyeTrack.pupil5(1:stopframe,2)];
        LED = [ReyeTrack.LED(1:stopframe,1),ReyeTrack.LED(1:stopframe,2)];
    end

            

%%%%%%%%%%%%iterativeplot('Select Area of Eye, then Artifact',artifact,nasal,temporal,p1,Cam)
            vectorizedplot('Select Area of Eye',nasal,temporal,p1,p2,p3,p4,p5,LED)
            
            [xv,yv] = ginput(2);
            [nasal,temporal,p1,p2,p3,p4,p5,LED] = clean(nasal,temporal,p1,p2,p3,p4,p5,LED,xv,yv);
            
%%%%%%%%%%%%Clean LED:
            empty = nan(size(p1));
            vectorizedplot('Select Area of LED',nasal,temporal,empty,empty,empty,empty,empty,LED)
            [xl,yl] = ginput(2);
            [LED] = cleanLED(LED,xl,yl);
            %Stabilize to LED
            [LED,nasal,temporal,p1,p2,p3,p4,p5] = stabilizetoLED(LED,nasal,temporal,p1,p2,p3,p4,p5);
            
%%%%%%%%%%%%iterativeplot('LEDStable',artifact,nasal,temporal,p1,Cam)
            vectorizedplot('Select Nasal, then Temporal',nasal,temporal,empty,empty,empty,empty,empty,LED)
            
            [xn,yn] = ginput(2);
            [xt,yt] = ginput(2);
            [nasal,temporal] = cleanNasoTemp(nasal,temporal,xn,yn,xt,yt);
            
%%%%%%%%%%%%iterativeplot('LEDStable',artifact,nasal,temporal,p1,Cam)
            vectorizedplot('Final',nasal,temporal,p1,p2,p3,p4,p5,LED)
            answer = questdlg('Look good?','Checkpoint Charlie','Yes');
            if strcmp(answer,'Yes') == 1
                gocode = 1;
            else
            end
    end
    
    %taking out the trash:
    clear answer
    clear empty
    clear gocode
    clear temp
    clear varargin
    clear xl
    clear xn
    clear xt
    clear xv
    clear yl
    clear yn
    clear yt
    clear yv
    
    if isequal(choice,'Leye')
        save('CleanLeye','p1','p2','p3','p4','p5','LED','nasal','temporal');        
        close all;
    elseif isequal(choice,'Reye')
        save('CleanReye','p1','p2','p3','p4','p5','LED','nasal','temporal');        
        close all;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%    Functions     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vectorizedplot(titlestring,nasal,temporal,p1,p2,p3,p4,p5,LED)
figure;
plot(nasal(:,1),nasal(:,2),'c.','MarkerSize',5)
hold on;
plot(temporal(:,1),temporal(:,2),'g.','MarkerSize',5)
plot(p1(:,1),p1(:,2),'k.','MarkerSize',5)
plot(p2(:,1),p2(:,2),'k.','MarkerSize',5)
plot(p3(:,1),p3(:,2),'k.','MarkerSize',5)
plot(p4(:,1),p4(:,2),'k.','MarkerSize',5)
plot(p5(:,1),p5(:,2),'k.','MarkerSize',5)
plot(LED(:,1),LED(:,2),'b.','MarkerSize',5)
title(string(titlestring))
set(gca,'Ydir','reverse')
end

function [nasal,temporal,p1,p2,p3,p4,p5,LED] = clean(nasal,temporal,p1,p2,p3,p4,p5,LED,xv,yv)
    for i = 1:length(nasal)
        if inpolygon(nasal(i,1),nasal(i,2),xv,yv) == 0
            nasal(i,:) = [nan,nan];
        end
        if inpolygon(temporal(i,1),temporal(i,2),xv,yv) == 0
            temporal(i,:) = [nan,nan];
        end
        if inpolygon(p1(i,1),p1(i,2),xv,yv) == 0
            p1(i,:) = [nan,nan];
        end
        if inpolygon(p2(i,1),p2(i,2),xv,yv) == 0
            p2(i,:) = [nan,nan];
        end
        if inpolygon(p3(i,1),p3(i,2),xv,yv) == 0
            p3(i,:) = [nan,nan];
        end
        if inpolygon(p4(i,1),p4(i,2),xv,yv) == 0
            p4(i,:) = [nan,nan];
        end
        if inpolygon(p5(i,1),p5(i,2),xv,yv) == 0
            p5(i,:) = [nan,nan];
        end
        if inpolygon(LED(i,1),LED(i,2),xv,yv) == 0
            LED(i,:) = [nan,nan];
        end
    end
end

function [LED] = cleanLED(LED,xl,yl)
    for i = 1:length(LED)
        if inpolygon(LED(i,1),LED(i,2),xl,yl) == 0
            LED(i,:) = [nan,nan];
        end
    end
end

function [LED,nasal,temporal,p1,p2,p3,p4,p5] = stabilizetoLED(LED,nasal,temporal,p1,p2,p3,p4,p5)
            nasal = nasal-LED;
            temporal = temporal-LED;
            p1 = p1-LED;
            p2 = p2-LED;
            p3 = p3-LED;
            p4 = p4-LED;
            p5 = p5-LED;
            LED = LED-LED;
end

function [nasal,temporal] = cleanNasoTemp(nasal,temporal,xn,yn,xt,yt)
    for i = 1:length(nasal)
        if inpolygon(nasal(i,1),nasal(i,2),xn,yn) == 0
            nasal(i,:) = [nan,nan];
        end
        if inpolygon(temporal(i,1),temporal(i,2),xt,yt) == 0
            temporal(i,:) = [nan,nan];
        end
    end
end

function [artifact,nasal,temporal,p1,p2,p3,p4,p5,LED,Cam] = rotateEverything(artifact,nasal,temporal,p1,p2,p3,p4,p5,LED,Cam,ImCenter)
            artifact = rotation(artifact,ImCenter,180);
            nasal = rotation(nasal,ImCenter,180);
            temporal = rotation(temporal,ImCenter,180);
            p1 = rotation(p1,ImCenter,180);
            p2 = rotation(p2,ImCenter,180);
            p3 = rotation(p3,ImCenter,180);
            p4 = rotation(p4,ImCenter,180);
            p5 = rotation(p5,ImCenter,180);
            LED = rotation(LED,ImCenter,180);
            Cam = rotation(Cam,ImCenter,180);
end