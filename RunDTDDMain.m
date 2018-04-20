
% Call in GUI:
%  [Rt,Mu,Sig]=DTDDMain(n,HH,MM,Kz,irr,maxZ);
% and the signature is
% function [Rt,Mu,Sig] = DTDDMain(n,HH,MM,Kz,irr,maxZ)

% irr is a 1x721 array in the default state.
% 721 = 1 + 60*12
tic
% kZ is input here in cm^2/s, for consistency with the old code.
% kZ = 10;  % original value as received
% Be careful when changing values in kZ, and be sure to review the Kz vs. depth
% plot which results.  
kZ = [[  0,  10,  85,  95, 100, 105, 115, 200];
      [ 10, 100, 100, 1.5,   1, 1.5,  10,  10]]';
DTDDMain(4, 18, 0, kZ, 150);
% short run for test:
%DTDDMain(5, 8, 0, 10, 100);
toc