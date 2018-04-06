function [irr] = irrCall_quiet(source,eventdata )
%IRRCALL_QUIET This function performs the same operation as the irrCall
%function within the DTDDGui function.  This one simply does not produce a
%plot as part of that.
%   This is to be used when the user has not already loaded irradiance data
%   by viewing a plot of the irradiance profile.
%{
a=path;
b=strfind(a,'Dropbox');
semC = strfind(a,';');
if semC(1)<b(1)
    dropPath=a(semC(1)+1:b(1)-1);
else
    dropPath=a(1:b(1)-1);
end
irr=importdata([dropPath 'Dropbox\MLML Student Data\Matlab Programs\NicksModel\dayIrr.mat']); % getting our daily irradiance values <-single vector (irr)
%}
irr=importdata('dayIrr.mat');
% irr is a vector with solar irradiance values from 06:00 to 18:00 every
% 5 minutes.  We are going to interpolate the 5 minute data onto a time
% vector that is every 1 minute so we have the values needed to run this
% siumulation.  For that we will need some time vectors
oldT=datenum(2014,07,24,06,00,00):datenum(00,00,00,00,05,00):datenum(2014,07,24,18,00,00);
newT=datenum(2014,07,24,06,00,00):datenum(00,00,00,00,01,00):datenum(2014,07,24,18,00,00);
irr=interp1(oldT,irr,newT,'spline');
clear oldT;
irr(irr<0)=0; % no such thing as negative irradiance
irr=(irr./max(irr)); % values are going a bit above 1 for some points
% We need values from 0 to 1 for the next section to make sense so we are
% getting a percentage of irradiance.

irr=irr*100; %The values in irr run from 0 to 1.  Nick wants



end

