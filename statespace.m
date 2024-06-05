%% Matlab code to extract state space model from Bladed linearisation
%% and create transfer functions for pitch or torque to gen speed for full envelope of wind speeds.
%% DT August 2022

linmod = load('linmod1.mat');

A = linmod.SYSTURB.A(:,:,:);
B = linmod.SYSTURB.B(:,:,:);
C = linmod.SYSTURB.C(:,:,:);
D = linmod.SYSTURB.D(:,:,:);

for i = 1:size(A)(3)
    sys{i} = ss(A(:,:,i), B(:,:,i), C(:,:,i), D(:,:,i),...
    'inputname', cellstr(linmod.SYSTURB.inputname),...
    'outputname', cellstr(linmod.SYSTURB.outputname),...
    'statename', cellstr(linmod.SYSTURB.statename));
end