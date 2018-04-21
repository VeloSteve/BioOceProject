function [Rt] = NickEq2(Re,Ro,r,t)
%NickEq2 This function calculates ratio of DT/DD at time t using equation 2
%in Nick's NSF proposal
%   INPUTS:
%       Re - Equilibrium ratio of DT/DD in the absence of mixing
%       Ro - Initial ratio of DT/DD
%       r - reaction rate of xanthophyll cycling (h^-1)
%       t - time (h)
%   OUTPUTS:
%       Rt - ratio of DT/DD at time t

    % we are breaking down the terms used in the following equation:
        % Rt=Re-(Re-Ro)*exp(-r*t)
    % this is being done to ensure that elementwise operations are carred
    % out at each step, thus allowing us to input large vectors rather than
    % just single values and have the equation behave properly.
    
    t1 = (Re-Ro); 
    t2 = exp(-r*t);
    t3 = t1*t2;
    Rt = Re-t3;
end

