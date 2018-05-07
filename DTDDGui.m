function DTDDGui(varargin)
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
set(f,'Name','Diatoxanthin/Diadinoxanthin mixing simulation')
%Initializing the app data we will use to hold our values.  This will let
%the callback functions be kept separate and reduce the memory load while
%still passing the necessary values from those callback functions to the
%main function.
% TODO: most of these values are set here, and then initialized in the
% uicontrols with hardwired text which could easily get out of sync.  Bad.
setappdata(f,'nValue',5)
setappdata(f,'HVal','12')
setappdata(f,'MVal','00')
setappdata(f,'ZVal',120)
setappdata(f,'Kz',[10, 100, 100, 1.5, 1, 1.5, 10, 10])
setappdata(f,'KzDepth',[0, 10, 85, 95, 100, 105, 115, 200])
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
    'Callback',{@irrCall_local, true});
irrText=uicontrol('Style','text','String','View Irradiance Profile',...
    'Position',[290,250,120,15],'FontAngle','italic');
stopText=uicontrol('Style','text','String','Set simulation end time',...
    'Position', [50, 180, 140,15],'FontAngle','italic');
startText=uicontrol('Style','text','String','Simulation starts at 06:00',...
    'Position', [50, 120, 140,30],'ForegroundColor','red','FontAngle','italic');
endTimeH = uicontrol('Style','edit','String',getappdata(f,'HVal'),'Position',[75,155,20,20],...
    'CallBack',{@setEndH_Call});
endTLabel=uicontrol('Style','text','String','HH','Position',[100,157,25,15],...
    'FontAngle','italic');
endTimeM=uicontrol('Style','edit','String',getappdata(f,'MVal'),'Position',[130,155,20,20],...
    'Callback',{@setEndM_Call});
endMLabel=uicontrol('Style','text','String','MM','Position',[155,157,25,15],...
    'FontAngle','italic');
nText = uicontrol('Style','text','String','Set # of particles: 10^n',...
    'Position',[45, 250,160,15],'FontAngle','italic');
nBox = uicontrol('Style','edit','String','5','Position',[100,220,20,20],...
    'Callback',{@SetN_Call});
zText=uicontrol('Style','text','String','Set water column depth (m)',...
    'Position', [290,180,140,15],'FontAngle','italic');
zVal=uicontrol('Style','edit','String',num2str(getappdata(f, 'ZVal')),'Position',[340,155,30,20],...
    'Callback',{@SetZ_Call});

kText=uicontrol('Style','text','String','Set Kz values (cm^2/s)',...
    'Position',[50, 105, 140,15],'FontAngle','italic');
kVal=uicontrol('Style','edit','String',num2str(getappdata(f, 'Kz'), '%2g '), ...
    'Position',[30,80,180,20],...
    'Callback',{@SetKz_Call});

kdText=uicontrol('Style','text','String','Set Kz depths (m)',...
    'Position',[50, 55, 140,15],'FontAngle','italic');
kdVal=uicontrol('Style','edit','String',num2str(getappdata(f, 'KzDepth'), '%2g '), ...
    'Position',[30,30,180,20],...
    'Enable', 'on', 'Callback',{@SetKd_Call});
kdWarn=uicontrol('Style','text','String','Number of depths must match Kz',...
    'Position',[30, 15, 180,15],'FontAngle','italic', ...
    'Enable', 'off', 'ForegroundColor',[1, 0, 0]);

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
    function irrCall_local(object,eventdata)
        % If called directly from the graph viewing button, this appears to
        % set irr values, but applies them to the wrong object!
        % Admittedly this doesn't matter because the call at the start of this
        % program sets the same values...
        irrCall(f, [], true);
    end
    function SetKz_Call(object,eventdata)
        Kz=str2double(get(object,'String'));
        if isnan(Kz)
            Kz = str2double(strsplit(strtrim(get(object, 'String')), {',',' '}));
        end
        if any(isnan(Kz))
            object.BackgroundColor = [1, 0.2, 0.2];
        else
            object.BackgroundColor = [1, 1, 1];
        end
        if length(Kz) == 1
            Kz = Kz(1);
            setappdata(f, 'KzDepth', 0);
            kdVal.String = '';
            kdVal.Enable = 'off';
        else
            kdVal.Enable = 'on';
        end
       setappdata(f,'Kz',Kz)
    end
    function SetKd_Call(object,eventdata)
        disp('In SetKd_Call!')
        KzD = str2double(get(object,'String'));
        if isnan(KzD)
            KzD = str2double(strsplit(strtrim(get(object, 'String')), {',',' '}));
        end
        if any(isnan(KzD))
            object.BackgroundColor = [1, 0.2, 0.2];
        else
            object.BackgroundColor = [1, 1, 1];
        end
        if length(KzD) == 1
            KzD = KzD(1);
            object.BackgroundColor = [1, 1, 0.2];
        end
        kvals = getappdata(f, 'Kz');
        if length(kvals) ~= length(KzD)
            object.BackgroundColor = [1, 1, 0.2];
            kdWarn.Enable = 'on';
        else
            kdWarn.Enable = 'off';
        end
       setappdata(f,'KzDepth',KzD)
    end
    function varagout=RunSim_Call(object,eventdata)
        % getting the values from our user input appdata
        n=getappdata(f,'nValue');
        HH=str2double(getappdata(f,'HVal'));MM=str2double(getappdata(f,'MVal'));
        Kz=getappdata(f,'Kz');maxZ=getappdata(f,'ZVal');irr=getappdata(f,'irrVals');
        KzDepth = getappdata(f, 'KzDepth');
        if length(Kz) > 1
            if length(Kz) == length(KzDepth)
                KzOut = [KzDepth', Kz'];
                disp(KzOut);
            else
                error('Number of depths and Kz values must match!');
            end    
        else
            KzOut = Kz;
        end
        
        [Rt,Mu,Sig]=DTDDMain(n,HH,MM,KzOut,irr,maxZ);
        assignin('base','Rt_DTDD',Rt)
        assignin('base','Mean_DTDD',Mu)
        assignin('base','Var_DTDD',Sig)
        delete(f)
    end
waitfor(f)
end

