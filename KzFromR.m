function [Kz] = KzFromR(Req, R, z1, r)
% Compute an estimated Kz value at depth(s) z1, based on the relationship
% between equilibrium and time-varying values of R = DT/DD.  This function
% assumes that incoming R values are at 1-meter intervals, starting at 0.

% Page 12 of [scan from a proposal by Nick Welschmeyer] gives an equation for
% this.  To translate to code terms, let
% Rint = integral from z1 to 0 of (R-Req)
% slope = dR/dZ at z1
% Kz = -r * Rint / slope
% 
% Units:
% Req and R are dimensionless
% z in meters
% r is minutes^-1
% so...
% Rint is meters
% slope is meters ^-1
% Kz is m^2/min
%
% Units in GUI input are cm^2/sec, converted m^2/sec internally.
% Convert this functions output to minutes.
Rdiff = R-Req;
if length(z1) == 1
    Rint = -trapz(Rdiff(1:z1));  
    slope = (R(z1+1) - R(z1-1))/2;
    Kz = -r * Rint / slope;
elseif length(z1) <= length(Req)
    Rint = -cumtrapz(Rdiff);
    slope = gradient(R);
    Kz = -r * Rint ./ slope;
    % Plot components - what's up?
    figure()
    plot(Rint, z1);
    hold on;
    plot(slope, z1);
    plot(Kz, z1);
    set(gca,'YDir','reverse','XAxisLocation','Top')
    legend({'Rdiff integral','slope','Estimate'},'location','best', ...
        'FontSize', 18);
    hold off;
else
    error('Do not ask for Kz over a wider range than the depths computed.')
end
Kz = Kz/60.0;
end
