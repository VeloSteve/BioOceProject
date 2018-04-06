function [R] = NickEq1(I)
%NickEq1 This function computes the equation used to describe the ratio of
%daitoxanthin to diadinoxanthin at a steady state as a function of light.
% i.e. Req
%   INPUTS:
%       I - light irrandiance
%   OUTPUTS:
%       R - Ratio of diatoxanthin to diadinoxanthin at equilibrium

a = .1; % y-intercept = min R value
b = 0.024; % slope

    R = a+b.*I; % dot notation is required to ensure this will function
               % properly even if I is a long vector of values.


end

