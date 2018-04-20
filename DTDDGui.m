function [f] = DTDDGui(varargin)
%DTDDGUI This function runs the GUI by which users interact with the DTDD
%simulation.
%   This function generates a GUI that users will use to run the DT/DD
%   simulation according to the formulas provided by Nick Welchmeyer.  It
%   will call several other functions not included here and will, as a
%   result need to be packaged as an app.
%{
if nargout <2
   warning(['If you do not specify 2 output variables then '...
       'only mean DT/DD values for each meter of water will be output.  '...
       'If you wish to get both mean and variance, please specify'...
       ' two output variables.'])
  
end
%}
% creating and hiding the GUI as it is being built
f=figure('Visible','on','Position',[2360,200,450,385]);
set(f,'Name','Daitoxanthin/Diadinoxanthin mixing simulation')
%Initializing the app data we will use to hold our values.  This will let
%the callback functions be kept separate and reduce the memory load while
%still passing the necessary values from those callback functions to the
%main function.
setappdata(f,'nValue',5)
setappdata(f,'HVal','12')
setappdata(f,'MVal','00')
setappdata(f,'ZVal',100)
setappdata(f,'Kz',10)
irrCall(f,[], false)
%build GUI components
descstring=['This GUI is designed to allow you to simulate the motion of single '...
    'cell phytoplankton in the water column as a function of the vertical mixing '...
    'rate.  The user sets the number of phytoplankton, the time the simulation will ' ...
    'end, the mixing rate, and the depth of the water column we will consider.  ' ...
    'Individual phytoplankters are spaced evenly along the water column.'];
hdesc=uicontrol('Style','text','String',descstring,'ForegroundColor','blue',...
    'Position',[50,280,350,100]);
hirr=uicontrol('Style','pushbutton','String','Irradiance','Position',[315,220,70,20],...
    'Callback',{@irrCall, true});
irrText=uicontrol('Style','text','String','View Irradiance Profile',...
    'Position',[290,250,120,15],'FontAngle','italic');
stopText=uicontrol('Style','text','String','Set simulation end time',...
    'Position', [50, 180, 140,15],'FontAngle','italic');
startText=uicontrol('Style','text','String','Simulation starts at 06:00',...
    'Position', [50, 120, 140,30],'ForegroundColor','red','FontAngle','italic');
endTimeH = uicontrol('Style','edit','String','12','Position',[75,155,20,20],...
    'CallBack',{@setEndH_Call});
endTLabel=uicontrol('Style','text','String','HH','Position',[100,157,25,15],...
    'FontAngle','italic');
endTimeM=uicontrol('Style','edit','String','00','Position',[130,155,20,20],...
    'Callback',{@setEndM_Call});
endMLabel=uicontrol('Style','text','String','MM','Position',[155,157,25,15],...
    'FontAngle','italic');
nText = uicontrol('Style','text','String','Set # of particles: 10^n',...
    'Position',[45, 250,160,15],'FontAngle','italic');
nBox = uicontrol('Style','edit','String','5','Position',[100,220,20,20],...
    'Callback',{@SetN_Call});
zText=uicontrol('Style','text','String','Set water column depth (m)',...
    'Position', [290,180,140,15],'FontAngle','italic');
zVal=uicontrol('Style','edit','String','100','Position',[340,155,30,20],...
    'Callback',{@SetZ_Call});
kText=uicontrol('Style','text','String','Set Kz value (cm^2/s)',...
    'Position',[50, 90, 140,15],'FontAngle','italic');
kVal=uicontrol('Style','edit','String','10','Position',[100,60,30,20],...
    'Callback',{@SetKz_Call});
runSim=uicontrol('Style','pushbutton','String','Run Simulation',...
    'Position',[300,60,130,40],'FontSize',10,'FontWeight','bold',...
    'Callback',{@RunSim_Call});

% how to get the irradiance values:  getappdata(hirr,'irrVals')
% how to get the n values: getappdata(f,'nValue')
    function SetN_Call(object,eventdata)
        n=str2double(get(object,'String'));
        setappdata(f,'nValue',n)
        if n>=6
           msgbox(['a value of 6 or greater is likely to cause Matlab to run'...
               ' out of memory and/or slow your computer down extremely.  '...
               'Proceed with caution.'],'n value too high','warn')
        end
    end
    function setEndH_Call(object,eventdata)
        HH=get(object,'String');
        if str2double(HH) < 6
            h=msgbox(['End time for the simulation must be later than 06:00 '...
                'since this is the start time for the simulation'],...
                'Later End Time Needed','warn');
        end
        setappdata(f,'HVal',HH)
    end
    function setEndM_Call(object,eventdata)
        MM=get(object,'String');
        if str2double(getappdata(f,'HVal'))==6
           if str2double(MM) <= 0
              h=msgbox('If HH value is set to 06, MM value must be later than 00','Later End Time Needed','warn'); 
           end
        end
        setappdata(f,'MVal',MM)
    end
    function SetZ_Call(object,eventdata)
        Z = str2double(get(object,'String'));
        setappdata(f,'ZVal',Z)
    end
    function SetKz_Call(object,eventdata)
        Kz=str2double(get(object,'String'));
        setappdata(f,'Kz',Kz)
    end
    function varagout=RunSim_Call(object,eventdata)
        % getting the values from our user input appdata
        n=getappdata(f,'nValue');HH=getappdata(f,'HVal');MM=getappdata(f,'MVal');
        Kz=getappdata(f,'Kz');maxZ=getappdata(f,'ZVal');irr=getappdata(f,'irrVals');
        [Rt,Mu,Sig]=DTDDMain(n,HH,MM,Kz,irr,maxZ);
        assignin('base','Rt_DTDD',Rt)
        assignin('base','Mean_DTDD',Mu)
        assignin('base','Var_DTDD',Sig)
        delete(f)
    end
waitfor(f)
end

