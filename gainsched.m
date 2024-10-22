%% Matlab code to calculate gain scheduling parameters
%% Loads the operating points from bladed results and does linear fit to dQdB
%% DT August 2022

op_points = dlmread('operational_points.txt','\t',2,0);

% Assumes dQdB is column 2 and pitch angle is column 3. Column 1 is wind speed.
% dQdB in Nm/rad, pitch in rad
gs.dQdB = -op_points(:,2);
gs.beta = op_points(:,3) * 180 / pi;
% gs.beta = op_points(:,3);
gs.wind = op_points(:,1);

% Number of data points to remove from start so only above-rated data is used
gs.trim = 80; % should be the index of about 5deg pitch
gs.trimend = 180; % should be the index of about 20deg pitch

gs.gs = polyfit(gs.beta(gs.trim:gs.trimend), gs.dQdB(gs.trim:gs.trimend), 1);
% gs.gs = polyfit(gs.beta(gs.trim:end), gs.dQdB(gs.trim:end), 1);

% Normalisation angle in degrees
gs.Bn = 0;

gs.gsn = gs.gs ./ polyval(gs.gs, gs.Bn);

gs.angles = 0:0.1:35;
% gs.angles = gs.beta;
gs.gain = 1 ./ polyval(gs.gsn, gs.angles);

gs.mxc = polyfit(gs.angles*pi/180, 1./gs.gain, 1);

gs.M = gs.mxc(1);
gs.C = gs.mxc(2);

if(1)
    hold on;
    plot(gs.beta(1:gs.trim), gs.dQdB(1:gs.trim), '.g')
    plot(gs.beta(gs.trim:gs.trimend), gs.dQdB(gs.trim:gs.trimend), '.b')
    plot(gs.beta(gs.trimend:end), gs.dQdB(gs.trimend:end), '.g')
    plot(gs.beta, polyval(gs.gs, gs.beta), 'r')
    xlabel('Blade Pitch (deg)')
    ylabel('1 / (dq/dB)')
    grid on;
    hold off;
end