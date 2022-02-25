function [] = FitCircleGUI(SkyVideo,CircleBank)
%Get circles and come back to currentdir:
currentdir = pwd;
cd(CircleBank); 
test = dir('Circ*.mat'); cd(currentdir);
FigPosition = [234 42 1204 774];

%Try each circle:
for i = 1:length(test)
    CircleFile = strcat(test(i).folder,'\',test(i).name);
    load(CircleFile);

    temp = figure;
    set(temp,'Position',FigPosition);
    tempImage = image(read(SkyVideo,1));  hold on;

% % % % %     center = flipYcoordinate(Circ.center',SkySize);
    H=circle(Circ.center,Circ.radius,150,'.'); H.Color = 'w';
    [goodornot] = FitCircleGUIdialog1();

    if isequal(goodornot,1) %This circle works, so save it in local directory:
        close all
        CircString = strcat('Circ',num2str(i),'.mat');
        save(CircString,'Circ');
        break
        
    elseif isequal(goodornot,0) %Load and try the next circle
        close all
        
    elseif isequal(goodornot,2) %Manually enter circle
        while isequal(1,1)
        close all        
        %Input points:
        temp = figure;
        set(temp,'Position',FigPosition);
        tempImage = image(read(SkyVideo,1));  hold on;
        %     set(gca,'Ydir','reverse')
        [xv,yv] = ginput(3);
        close all
% % % % %         [outputxypts] = flipYcoordinate([xv,yv],SkySize);
% % % % %         Circ.input = outputxypts;
            
            %Fit circle:
            Circ.input = [xv,yv];
            [R,xcyc] = fit_circle_through_3_points(Circ.input);
            Circ.center = xcyc;
            Circ.radius = R;
            Circ.diameter = Circ.radius*2;
                
                %View/confirm circle:
                temp = figure;
                set(temp,'Position',FigPosition);
                tempImage = image(read(SkyVideo,1));  hold on;
                H=circle(Circ.center,Circ.radius,150,'.'); H.Color = 'w';
                [NewCircLooksGood] = FitCircleGUIdialog2();
        
        if isequal(NewCircLooksGood,1)
            %Save it in the bank:
            CircString = strcat('E:\Nick\Circles\Circ',num2str(length(test)+1),'.mat');
            save(CircString,'Circ')
            %save it in local directory:
            CircString = strcat('Circ',num2str(length(test)+1),'.mat');
            save(CircString,'Circ')
            %Then break out of loop:
            break
        end
        end
        
    end
end

end

function [goodornot] = FitCircleGUIdialog1()
answer = questdlg('Does this circle fit?', ...
	'Dessert Menu', ...
	'Yes','No','No, manually enter circle','No');
% Handle response
switch answer
    case 'Yes'
        disp([answer ' Saving circle'])
        goodornot = 1;
    case 'No'
        disp([answer ' Trying next circle'])
        goodornot = 0;
    case 'No, manually enter circle'
        disp([answer ' Going to manual entry'])
        goodornot = 2;
end
end
function [NewCircLooksGood] = FitCircleGUIdialog2()
answer = questdlg('Does this circle fit?', ...
	'Dessert Menu', ...
	'Yes','No, manually enter circle again','No, manually enter circle again');
% Handle response
switch answer
    case 'Yes'
        disp([answer ' Saving circle'])
        NewCircLooksGood = 1;
    case 'No, manually enter circle again'
        disp([answer ' Trying making circle again'])
        NewCircLooksGood = 0;
end
end