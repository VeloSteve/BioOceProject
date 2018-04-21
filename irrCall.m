function [] = irrCall( source, ~, showPlot, step_seconds )
%IRRCALL This function loads irrandiance data and plots it for the user
%   This is a callback function to be used as part of the DTDDGui.  It is
%   inteded to allow the user to visualize the irradiance values being used
%   in the simulation while providing them to the rest of the GUI.
    

irr=importdata('dayIrr.mat'); % getting our daily irradiance values <-single vector (irr)

% irr is a vector with solar irradiance values from 06:00 to 18:00 every
% 5 minutes.  We are going to interpolate the 5 minute data onto a time
% vector that is every 1 minute so we have the values needed to run this
% siumulation.  For that we will need some time vectors
oldT=datenum(2014,07,24,06,00,00):datenum(00,00,00,00,05,00):datenum(2014,07,24,18,00,00);
% The second datenum below was hardwired to 1 minute.  Allow for a variable step size
% in seconds.
if nargin > 3
    sMin = floor(step_seconds / 60);
    sSec = step_seconds - sM * 60;
else
    sMin = 1;
    sSec = 0;
end
newT=datenum(2014,07,24,06,00,00):datenum(00,00,00,00, sMin, sSec):datenum(2014,07,24,18,00,00);
irr=interp1(oldT,irr,newT,'spline');
clear oldT;
irr(irr<0)=0; % no such thing as negative irradiance
irr=100*(irr./max(irr)); % values are going a bit above 1 for some points
setappdata(source,'irrVals',irr);

% We need values from 0 to 1 for the next section to make sense so we are
% getting a percentage of irradiance.
% surfI=irr*100; %The values in irr run from 0 to 1.  Nick wants
% I values from 0 to 100 so we are modifying it.
if showPlot
    figure
    plot(newT,irr)
    tick1=get(gca,'Xtick');
    set(gca,'Xticklabel',datestr(tick1,15))
    xlabel('time of day')
    ylabel('Solar Insolation')
end
end

