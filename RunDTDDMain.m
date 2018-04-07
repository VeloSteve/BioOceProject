
% Call in GUI:
%  [Rt,Mu,Sig]=DTDDMain(n,HH,MM,Kz,irr,maxZ);
% and the signature is
% function [Rt,Mu,Sig] = DTDDMain(n,HH,MM,Kz,irr,maxZ)

% irr is a 1x721 array in the default state.
% 721 = 1 + 60*12
tic
irr = irrCall_noGUI();
DTDDMain(5, 18, 0, 10, irr, 100);
toc