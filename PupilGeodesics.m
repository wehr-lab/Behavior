function PupilGeodesics(varargin) %varargin{1} = 'Leye'or'Reye' varargin{2} = radius
choice = varargin{1};
radius = varargin{2}; %automate this with metric tensor
[p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe] = GetEye(choice);
[p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe,newlength] = LimitEye(p1,p2,p3,p4,p5,LED,nasal,temporal,startframe,stopframe);
gocode = 0;
easyblue = [ 0    0.4470    0.7410];

while(gocode == 0)
    close all

    %Get ellipses
    [~,~,~,~,~,X0_in,Y0_in,long_axis,short_axis] = ellipsematrix(p1,p2,p3,p4,p5,newlength);

    %Search for Zenith pole using Tissot's indicatrix
    Tissot_Idx = nan(newlength,1);
    for i = 1:newlength
        Tissot_Idx(i,1) = short_axis(i,1)/long_axis(i,1);
    end
    x = X0_in(~isnan(X0_in));
    y = Y0_in(~isnan(Y0_in));
    Ti = Tissot_Idx(~isnan(Tissot_Idx));

    fitobject = fit([x,y],Ti,'lowess');
    z = feval(fitobject,[x,y]);
    surfmin = max(z); %Surface minimum
    surfmindex = find(z == surfmin);
    surfminX = x(surfmindex); %Surface minimum X
    surfminY = y(surfmindex); %Surface minimum Y
    surfminXY = [surfminX,surfminY];

    aveX = mean([LED(1,1),round(surfminX)]); %Average pole X
    aveY = mean([LED(1,2),round(surfminY)]); %Average pole Y
    aveXY = [aveX,aveY];
    avenasal = nanmean(nasal);
    avetemporal = nanmean(temporal);
    
    figure;
    sortedTi = sort(Ti,'descend');
    cmap = [linspace(1,0,length(x))',zeros(length(x),1),linspace(1,0,length(x))'];
    subplot(1,2,1)
    for i = 1:length(x)
        inputcolor = cmap(sortedTi==Ti(i),:);
        inputcolor = inputcolor(1,:);
        plot(x(i),y(i),'.','MarkerSize',10,'Color',inputcolor)
        hold on;
    end
    plot(nasal(:,1),nasal(:,2),'v','MarkerSize',5,'Color',easyblue)
    plot(temporal(:,1),temporal(:,2),'+','MarkerSize',5,'Color',easyblue)
    plot(LED(:,1),LED(:,2),'k.','MarkerSize',20)
    plot(surfminX,surfminY,'m.','MarkerSize',20)
    plot(aveX,aveY,'.','Color',[0.5,0,0.5],'MarkerSize',20)
    plot(avenasal(1),avenasal(2),'vb','MarkerSize',15,'LineWidth',3);
    plot(avetemporal(1),avetemporal(2),'+b','MarkerSize',15,'LineWidth',3);
    title('Orthographic Coordinates')
    xlabel('X Coordinate')
    ylabel('Y Coordinate')
    grid on;
    
    colormap(cmap)
    c = colorbar;
    c.Location = 'north';
    c.Position = [0.2 0.8 0.2 0.025];
    c.Ticks = [0,1];
    c.TickLabels = {num2str(round(max(sortedTi),2)),num2str(round(min(sortedTi),2))};
    c.Label.String = 'Tissot Indicatrix Value';
    c.Label.Position = [0.5000    -2         0];
    set(c, 'YDir', 'reverse');
    
    yl = ylim;
    xl = xlim;
    biglim = max([abs(xl(1)),abs(xl(2)),abs(yl(1)),abs(yl(2))]);
    ylim([-biglim,biglim]);
    xlim([-biglim,biglim]);
    set(gca,'Ydir','reverse')
    axis square
    hold off;
    
    subplot(1,2,2)
    for i = 1:length(x)
        inputcolor = cmap(sortedTi==Ti(i),:);
        inputcolor = inputcolor(1,:);
        plot3(x(i),y(i),Ti(i),'.','MarkerSize',10,'Color',inputcolor)
        hold on;
    end
    grid on;
    hold on;
    plot3([LED(1,1),LED(1,1)],[LED(1,2),LED(1,2)],[0,1.2],'k-','LineWidth',5)
    plot3([surfminX,surfminX],[surfminY,surfminY],[0,1.2],'m-','LineWidth',5)
    plot3([aveX,aveX],[aveY,aveY],[0,1.2],'-','Color',[0.5,0,0.5],'LineWidth',5);
%     plot(fitobject, [x, y], Ti);
    zmins = ones(size(nasal,1),1);
    zmaxs = (min(Ti))*zmins;
    plot3(avenasal(1),avenasal(2),0,'v','MarkerSize',15,'LineWidth',3,'Color',easyblue);
    plot3(avenasal(1),avenasal(2),1,'v','MarkerSize',15,'LineWidth',3,'Color',easyblue);
    plot3(avetemporal(1),avetemporal(2),0,'+','MarkerSize',15,'LineWidth',3,'Color',easyblue);
    plot3(avetemporal(1),avetemporal(2),1,'+','MarkerSize',15,'LineWidth',3,'Color',easyblue);
    ylim([-biglim,biglim]);
    xlim([-biglim,biglim]);
    set(gca,'Ydir','reverse')
    title('Tissot Zenith pole')
    xlabel('Xaxis')
    ylabel('Yaxis')
    zlabel('Tissot Value')
    plotCircle3D([0,0,0.7482], [0,0,1], 40) %60 N
    plotCircle3D([0,0,0.2077], [0,0,1], 95) %30 N
    set(gcf, 'Position',  [498   575   985   420])
    hold off;

    %Shift origin to [surfminX,surfminY];
    nasal = nasal-surfminXY;
    temporal = temporal-surfminXY;
    p1 = p1-surfminXY;
    p2 = p2-surfminXY;
    p3 = p3-surfminXY;
    p4 = p4-surfminXY;
    p5 = p5-surfminXY;
    LED = LED-surfminXY;
    
    %Get ellipses in zenith-centered plane
    [~,~,~,~,~,X0_in,Y0_in,long_axis,short_axis] = ellipsematrix(p1,p2,p3,p4,p5,newlength);

%%%%%%%%%%%%iterativeplot('Zenith-Centered',nasal,temporal,p1,Cam)
%     vectorizedplot('Zenith-Centered',nasal,temporal,[X0_in,Y0_in],LED)

    avenasal = nanmean(nasal);
    avetemporal = nanmean(temporal);
    
    Tissot_Idx = nan(newlength,1);
    for i = 1:newlength
        Tissot_Idx(i,1) = short_axis(i,1)/long_axis(i,1);
    end
    x = X0_in(~isnan(X0_in));
    y = Y0_in(~isnan(Y0_in));
    Ti = Tissot_Idx(~isnan(Tissot_Idx));
    
    for i = 1:length(x)
        r(i,1) = (pdist([[0,0];[x(i),y(i)]]));
        R(i,1) = ((r(i,1)) / (sqrt( 1 - ((Ti(i))^2) ))); 
    end
    
    figure
    subplot(1,2,1)
        plot(R)
        hold on
        plot(r,'r')
        plot(((Ti)*100),'g')
        maxradius = max(R);
        hold off;
        
        [r,I] = sort(r);
        R = R(I,:);
        Titemp = Ti(I,:);
        
    subplot(1,2,2)
        plot(r,'r')
        hold on
        plot(R)
        plot(((Titemp)*100),'g')
        
%         maxradius = max(R);
%             plot([1,length(x)],[maxradius(1),maxradius(1)],'k-')

        nastemprad = nanmean((pdist([nasal(1);temporal(1)],'euclidean')))/2;
            plot([0,length(x)],[nastemprad(1),nastemprad(1)],'b-')

        nasradius = (pdist([[0,0];avenasal(1,:)],'euclidean'));
            plot([0,length(x)],[nasradius(1),nasradius(1)],'v','Color',easyblue)

        tempradius = (pdist([[0,0];avetemporal(1,:)],'euclidean'));
            plot([0,length(x)],[tempradius(1),tempradius(1)],'+','Color',easyblue)
            set(gcf, 'Position',  [498    94   985   420])

%%%%%%%%%%%%        Unproject onto sphere               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:newlength
        [p1x(i,1),p1y(i,1),p1z(i,1)] = Cartesian2Cartesian3(p1(i,1),p1(i,2),radius);
        [p2x(i,1),p2y(i,1),p2z(i,1)] = Cartesian2Cartesian3(p2(i,1),p2(i,2),radius);
        [p3x(i,1),p3y(i,1),p3z(i,1)] = Cartesian2Cartesian3(p3(i,1),p3(i,2),radius);
        [p4x(i,1),p4y(i,1),p4z(i,1)] = Cartesian2Cartesian3(p4(i,1),p4(i,2),radius);
        [p5x(i,1),p5y(i,1),p5z(i,1)] = Cartesian2Cartesian3(p5(i,1),p5(i,2),radius);
        [LEDx(i,1),LEDy(i,1),LEDz(i,1)] = Cartesian2Cartesian3(LED(i,1),LED(i,2),radius);

        [pupx(i,1),pupy(i,1),pupz(i,1)] = Cartesian2Cartesian3(X0_in(i),Y0_in(i),radius);
        [nasalx(i,1),nasaly(i,1),nasalz(i,1)] = Cartesian2Cartesian3(nasal(i,1),nasal(i,2),radius);
        [tempx(i,1),tempy(i,1),tempz(i,1)] = Cartesian2Cartesian3(temporal(i,1),temporal(i,2),radius);
    end
    p1 = [p1x,p1y*-1,p1z*-1];
    p2 = [p2x,p2y*-1,p2z*-1];
    p3 = [p3x,p3y*-1,p3z*-1];
    p4 = [p4x,p4y*-1,p4z*-1];
    p5 = [p5x,p5y*-1,p5z*-1];
    LED = [LEDx,LEDy*-1,LEDz*-1];
    pup = [pupx,pupy*-1,pupz*-1];
    nasal = [nasalx,nasaly*-1,nasalz*-1];
    temporal = [tempx,tempy*-1,tempz*-1];

    [avenasalx,avenasaly,avenasalz] = Cartesian2Cartesian3(avenasal(1),avenasal(2),radius);
    avenasal = [avenasalx,avenasaly*-1,avenasalz*-1];

    [avetemporalx,avetemporaly,avatemporalz] = Cartesian2Cartesian3(avetemporal(1),avetemporal(2),radius);
    avetemporal = [avetemporalx,avetemporaly*-1,avatemporalz*-1];

%%%%%%%%%%%%        Plot                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[avenasalLat,avenasalLon] = Cartesian2Spherical(avenasal(1),avenasal(2),avenasal(3));
[avetemporalLat,avetemporalLon] = Cartesian2Spherical(avetemporal(1),avetemporal(2),avetemporal(3));
[latax,lonax] = track2('gc',avetemporalLat,avetemporalLon,avenasalLat,avenasalLon);
for i = 1:length(latax)
    [xax(i),yax(i),zax(i)] = Spherical2Cartesian(latax(i),lonax(i));
end
sortedTi = sort(Ti,'descend');
cmap = [linspace(1,0,length(x))',zeros(length(x),1),linspace(1,0,length(x))'];
puptemp = [];
for i = 1:length(sortedTi)
    if any(~isnan(pup(i,:)))
        puptemp = [puptemp ; pup(i,:)];
    end
end

    figure;
    plot3(xax,yax,zax,'.','MarkerSize',10);
    hold on;
    plot3(xax(50),yax(50),zax(50),'c.','MarkerSize',30);
    plot3(avenasal(1),avenasal(2),avenasal(3),'vb','MarkerSize',15,'LineWidth',3,'Color',easyblue);
    plot3(avetemporal(1),avetemporal(2),avetemporal(3),'+b','MarkerSize',15,'LineWidth',3,'Color',easyblue);
    for i = 1:length(puptemp)
%         plot3(nasal(i,1),nasal(i,2),nasal(i,3),'v','Color',easyblue);
%         plot3(temporal(i,1),temporal(i,2),temporal(i,3),'+','Color',easyblue);
        if any(~isnan(puptemp(i)))
            plot3(puptemp(i,1),puptemp(i,2),puptemp(i,3),'.','Color',cmap(sortedTi==Ti(i),:));
        else
        end
%         set(gca,'DataAspectRatio',[1 1 1])
%         xlim([-1,1]);
%         ylim([-1,1]);
%         zlim([0,1]);
%         view(2)
%         xlabel('Xaxis')
%         ylabel('Yaxis')
%         zlabel('Zaxis')
%         plotCircle3D([0,0,0], [0,0,1], 1) %equator
%         plotCircle3D([0,0,0], [1,0,0], 1) %meridian
%         plotCircle3D([0,0,0], [0,1,0], 1) %antimerid
        grid on;
    end
    set(gca,'DataAspectRatio',[1 1 1])
    xlim([-1,1]);
    ylim([-1,1]);
    zlim([0,1]);
    view(2)
    xlabel('Xaxis')
    ylabel('Yaxis')
    zlabel('Zaxis')
    plotCircle3D([0,0,0], [0,0,1], 1) %equator
    plotCircle3D([0,0,0], [1,0,0], 1) %meridian
    plotCircle3D([0,0,0], [0,1,0], 1) %antimerid
%     set(gcf, 'OuterPosition',  [664   562   567   519])
%     set(gcf, 'Position',  [672   570   551   426])
    axis vis3d
    hold off;

%%%%%%%%%%%%        Transform to LatLon     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:newlength
        [p1Lat(i),p1Lon(i)] = Cartesian2Spherical(p1(i,1),p1(i,2),p1(i,3));
        [p2Lat(i),p2Lon(i)] = Cartesian2Spherical(p2(i,1),p2(i,2),p2(i,3));
        [p3Lat(i),p3Lon(i)] = Cartesian2Spherical(p3(i,1),p3(i,2),p3(i,3));
        [p4Lat(i),p4Lon(i)] = Cartesian2Spherical(p4(i,1),p4(i,2),p4(i,3));
        [p5Lat(i),p5Lon(i)] = Cartesian2Spherical(p5(i,1),p5(i,2),p5(i,3));
        [LEDLat(i),LEDLon(i)] = Cartesian2Spherical(LED(i,1),LED(i,2),LED(i,3));
        [pupLat(i),pupLon(i)] = Cartesian2Spherical(pup(i,1),pup(i,2),pup(i,3));
        [nasalLat(i),nasalLon(i)] = Cartesian2Spherical(nasal(i,1),nasal(i,2),nasal(i,3));
        [tempLat(i),tempLon(i)] = Cartesian2Spherical(temporal(i,1),temporal(i,2),temporal(i,3));
    end
    [avenasalLat,avenasalLon] = Cartesian2Spherical(avenasal(1),avenasal(2),avenasal(3));
        nasalpoint = [avenasalLat,avenasalLon];
    [avetemporalLat,avetemporalLon] = Cartesian2Spherical(avetemporal(1),avetemporal(2),avetemporal(3));
        temporalpoint = [avetemporalLat,avetemporalLon];

%%%%%%%%%%%%        Shift Geodesic pole from relative-zenith to DV/NT     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    [latax,lonax] = track2('gc',avetemporalLat,avetemporalLon,avenasalLat,avenasalLon);
    origin = [latax(50),lonax(50)];
    
    if isequal(choice,'Leye')
        reflat=temporalpoint(1);
        reflon=temporalpoint(2);
    elseif isequal(choice,'Reye')
        reflat=nasalpoint(1);
        reflon=nasalpoint(2);
    end
    
    for i = 1:newlength
        [p1ca(1,i),p1theta(1,i)] = NewPole(p1Lat(i),p1Lon(i),origin(1),origin(2),reflat,reflon,latax,lonax);
        [p2ca(1,i),p2theta(1,i)] = NewPole(p2Lat(i),p2Lon(i),origin(1),origin(2),reflat,reflon,latax,lonax);
        [p3ca(1,i),p3theta(1,i)] = NewPole(p3Lat(i),p3Lon(i),origin(1),origin(2),reflat,reflon,latax,lonax);
        [p4ca(1,i),p4theta(1,i)] = NewPole(p4Lat(i),p4Lon(i),origin(1),origin(2),reflat,reflon,latax,lonax);
        [p5ca(1,i),p5theta(1,i)] = NewPole(p5Lat(i),p5Lon(i),origin(1),origin(2),reflat,reflon,latax,lonax);
        [pupca(1,i),puptheta(1,i)] = NewPole(pupLat(i),pupLon(i),origin(1),origin(2),reflat,reflon,latax,lonax);
    end
    [avenasalca,avenasaltheta] = NewPole(nasalpoint(1),nasalpoint(2),origin(1),origin(2),reflat,reflon,latax,lonax);
    [avetemporalca,avetemporaltheta] = NewPole(temporalpoint(1),temporalpoint(2),origin(1),origin(2),reflat,reflon,latax,lonax);
    avetemporaltheta = real(avetemporaltheta);
    avenasaltheta = real(avenasaltheta);
% % % % %     QuickPolarPlot was here

%%%%%%%%%%%%        Transform back to Cartesian 3d  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1:newlength
            [p1(i,1),p1(i,2),p1(i,3)] = sph2cart(p1theta(1,i),(pi/2)-(p1ca(1,i)),1);
            [p2(i,1),p2(i,2),p2(i,3)] = sph2cart(p2theta(1,i),(pi/2)-(p2ca(1,i)),1);
            [p3(i,1),p3(i,2),p3(i,3)] = sph2cart(p3theta(1,i),(pi/2)-(p3ca(1,i)),1);
            [p4(i,1),p4(i,2),p4(i,3)] = sph2cart(p4theta(1,i),(pi/2)-(p4ca(1,i)),1);
            [p5(i,1),p5(i,2),p5(i,3)] = sph2cart(p5theta(1,i),(pi/2)-(p5ca(1,i)),1);
            [pup(i,1),pup(i,2),pup(i,3)] = sph2cart(puptheta(1,i),(pi/2)-(pupca(1,i)),1);
        end
        [avenasal(1,1),avenasal(1,2),avenasal(1,3)] = sph2cart(avenasaltheta(1),(pi/2)-avenasalca,1);
        [avetemporal(1,1),avetemporal(1,2),avetemporal(1,3)] = sph2cart(avetemporaltheta(1),(pi/2)-avetemporalca,1);
        
        [avenasalLat,avenasalLon] = Cartesian2Spherical(avenasal(1),avenasal(2),avenasal(3));
        [avetemporalLat,avetemporalLon] = Cartesian2Spherical(avetemporal(1),avetemporal(2),avetemporal(3));
        [latax,lonax] = track2('gc',avetemporalLat,avetemporalLon,avenasalLat,avenasalLon);
        for i = 1:length(latax)
            [xax(i),yax(i),zax(i)] = Spherical2Cartesian(latax(i),lonax(i));
        end
%%%%%%%%%%%%        Plot    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure;
        plot3(xax,yax,zax,'.','MarkerSize',10);
        hold on;
        for i = 1:newlength
            if any(~isnan(pup(i)))
                plot3(pup(i,1),pup(i,2),pup(i,3),'.','Color',[cmap(sortedTi==Tissot_Idx(i)) 0 cmap(sortedTi==Tissot_Idx(i))]);
            end
%             view(2)
%             plot3(p1(i,1),p1(i,2),p1(i,3),'k.');
%             plot3(p2(i,1),p2(i,2),p2(i,3),'k.');
%             plot3(p3(i,1),p3(i,2),p3(i,3),'k.');
%             plot3(p4(i,1),p4(i,2),p4(i,3),'k.');
%             plot3(p5(i,1),p5(i,2),p5(i,3),'k.');

%             plot3(nasalx(i,1),nasaly(i,1),nasalz(i,1),'c.');
%             plot3(tempx(i,1),tempy(i,1),tempz(i,1),'g.');
%             plot3(avenasal(1),avenasal(2),avenasal(3),'c.','MarkerSize',20);
%             plot3(avetemporal(1),avetemporal(2),avetemporal(3),'g.','MarkerSize',20);
%             plot3(midpoint(1),midpoint(2),midpoint(3),'b.','MarkerSize',20);
%             plot3(0,0,1,'b.','MarkerSize',25);

%             xlim([-1,1]);
%             ylim([-1,1]);
%             zlim([-1,1]);
%             xlabel('Xaxis')
%             ylabel('Yaxis')
%             zlabel('Zaxis')
%             grid on;
            
%             hold off;
%             F(i) = getframe(gcf);
        end
%             plot3(X,Y,Z,'r.');
%             plot3(X(50,1), Y(50,1), Z(50,1),'g.','MarkerSize',20)
%             plot3(axX,axY,axZ,'b.');
%             plot3(axX(50,1),axY(50,1),axZ(50,1),'g.','MarkerSize',20)
%             plot3(avenasal(1),avenasal(2),avenasal(3),'c.','MarkerSize',20);
%             plot3(avetemporal(1),avetemporal(2),avetemporal(3),'g.','MarkerSize',20);
%             plot3(midpoint(1),midpoint(2),midpoint(3),'b.','MarkerSize',20);
        grid on;
        plot3(avetemporal(1,1),avetemporal(1,2),avetemporal(1,3),'+','MarkerSize',15,'LineWidth',3,'Color',easyblue);
        if isequal(choice,'Leye')
            plot3(avenasal(1,1),avenasal(1,2),avenasal(1,3),'<','MarkerSize',15,'LineWidth',3,'Color',easyblue);
        elseif isequal(choice,'Reye')
            plot3(avenasal(1,1),avenasal(1,2),avenasal(1,3),'>','MarkerSize',15,'LineWidth',3,'Color',easyblue);
        end
        plotCircle3D([0,0,0], [0,0,1], 1) %equator
        plotCircle3D([0,0,0], [1,0,0], 1) %meridian
        plotCircle3D([0,0,0], [0,1,0], 1) %antimerid
        xlim([-1,1]);
        ylim([-1,1]);
        zlim([0,1]);
        set(gca,'DataAspectRatio',[1 1 1])
        xlabel('Temporal --> Nasal')
        ylabel('Ventral --> Dorsal')
        zlabel('Zaxis')
        view(0,90);
%         set(gcf, 'OuterPosition',  [664    34   567   536])
%         set(gcf, 'Position',  [672    42   551   443])
        axis vis3d
        
    answer = questdlg('Look good?','Checkpoint','Yes');
    if strcmp(answer,'Yes') == 1
        gocode = 1;
    else
    end
end %end of While loop

if isequal(choice,'Leye')
    LeyeGeodesics = struct('pup',pup,'p1',p1,'p2',p2,'p3',p3,'p4',p4,'p5',p5,'LED',LED,'nasal',nasal,'temporal',temporal,'startframe',startframe,'stopframe',stopframe,'avetemporal',avetemporal,'avenasal',avenasal);
    save('LeyeGeodesics','LeyeGeodesics');
elseif isequal(choice,'Reye')
    ReyeGeodesics = struct('pup',pup,'p1',p1,'p2',p2,'p3',p3,'p4',p4,'p5',p5,'LED',LED,'nasal',nasal,'temporal',temporal,'startframe',startframe,'stopframe',stopframe,'avetemporal',avetemporal,'avenasal',avenasal);
    save('ReyeGeodesics','ReyeGeodesics');
end

end


function [CentralAngle,theta] = NewPole(lat,lon,originlat,originlon,reflat,reflon,latax,lonax) %proud of this one :)
    %Test if value is dorsal or ventral
    [tempx,tempy,tempz] = Spherical2Cartesian(latax,lonax);
    [testx,testy,testz] = Spherical2Cartesian(lat,lon);
    temp = abs(tempx-testx);
    [temp2,I] = sort(temp);
    if testy<tempy(I(1))
        flip = 1; %ventral
    else
        flip = 0; %dorsal
    end
    
    %convert to radians
    lat = lat*(pi/180);
    lon = lon*(pi/180);
    originlat = originlat*(pi/180);
    originlon = originlon*(pi/180);
    reflat = reflat*(pi/180);
    reflon = reflon*(pi/180);

    a = acos( ((sin(reflat))*(sin(originlat))) + ((cos(reflat))*(cos(originlat))*(cos(abs(reflon-originlon)))) );
    b = acos( ((sin(lat))*(sin(originlat))) + ((cos(lat))*(cos(originlat))*(cos(abs(lon-originlon)))) );
    c = acos( ((sin(lat))*(sin(reflat))) + ((cos(lat))*(cos(reflat))*(cos(abs(lon-reflon)))) );
    CentralAngle = b;
    
    alpha = (acos(((cos(a))-((cos(b))*(cos(c))))/((sin(b))*(sin(c)))));
    beta = (acos(((cos(b))-((cos(c))*(cos(a))))/((sin(c))*(sin(a)))));
    theta = (acos(((cos(c))-((cos(a))*(cos(b))))/((sin(a))*(sin(b)))));
%     surfacearea = (1)*( (alpha+beta+theta)-pi );

    if flip == 1
        theta = (2*pi)-theta;
    else
    end
end
function [newx,newy,z] = Cartesian2Cartesian3(x,y,r)
x = x/r;
y = y/r;
newx = ( (2*x)/(1+(x^2)+(y^2)) );
newy = ( (2*y)/(1+(x^2)+(y^2)) );
z = ((-1+(x^2)+(y^2))/(1+(x^2)+(y^2)));
end
function [a,b,phi,X0,Y0,X0_in,Y0_in,long_axis,short_axis] = ellipsematrix(p1,p2,p3,p4,p5,Tracklength)
%Get ellipses
ellipseproperties = {};
for i = 1:Tracklength
    if ~isnan([p1(i),p2(i),p3(i),p4(i),p5(i)])
        ellipse_t(i) = fit_ellipse([p1(i,1);p2(i,1);p3(i,1);p4(i,1);p5(i,1)],[p1(i,2);p2(i,2);p3(i,2);p4(i,2);p5(i,2)]);
        temp = struct2cell(ellipse_t(i))';
    else
        temp = cell(1,10);
    end
    for ii = 1:10
        ellipseproperties{i,ii} = temp{ii};
        if isempty(ellipseproperties{i,ii})
            ellipseproperties{i,ii} = nan;
        end
    end
end
a = cell2mat(ellipseproperties(:,1));
b = cell2mat(ellipseproperties(:,2));
phi = cell2mat(ellipseproperties(:,3));
X0 = cell2mat(ellipseproperties(:,4));
Y0 = cell2mat(ellipseproperties(:,5));
X0_in = cell2mat(ellipseproperties(:,6));
Y0_in = cell2mat(ellipseproperties(:,7));
long_axis = cell2mat(ellipseproperties(:,8));
short_axis = cell2mat(ellipseproperties(:,9));
end
function iterativeplot(titlestring,nasal,temporal,p1,Cam)
figure;
    for i = 1:length(nasal)
        plot(nasal(i,1),nasal(i,2),'c.','MarkerSize',5)
        hold on;
        plot(temporal(i,1),temporal(i,2),'g.','MarkerSize',5)
        plot(p1(i,1),p1(i,2),'k.','MarkerSize',10)
        plot(Cam(i,1),Cam(i,2),'b.','MarkerSize',10)
        if isempty(nasal) == 0
            plot(temporal(i,1),temporal(i,2),'r.','MarkerSize',10)
        else
        end
    end
title(string(titlestring))
set(gca,'Ydir','reverse')
end
function vectorizedplot(titlestring,nasal,temporal,ellipsecenter,LED)
figure;
plot(nasal(:,1),nasal(:,2),'c.','MarkerSize',5)
hold on;
plot(temporal(:,1),temporal(:,2),'g.','MarkerSize',5)
plot(ellipsecenter(:,1),ellipsecenter(:,2),'k.','MarkerSize',5)
plot(LED(:,1),LED(:,2),'b.','MarkerSize',5)
title(string(titlestring))
set(gca,'Ydir','reverse')
end