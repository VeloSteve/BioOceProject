
% Call in GUI:
%  [Rt,Mu,Sig]=DTDDMain(n,HH,MM,Kz,irr,maxZ);
% and the signature is
% function [Rt,Mu,Sig] = DTDDMain(n,HH,MM,Kz,irr,maxZ)

% irr is a 1x721 array in the default state.
% 721 = 1 + 60*12
tic
DTDDMain(5, 18, 0, 10, 100);
% short run for test:
%DTDDMain(5, 8, 0, 10, 100);
toc