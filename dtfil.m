%% Matlab code for designing a drivetrain filter
%% DT August 2022

dt_w = 15.2; % First drivetrain mode frequency in rad/s
dt_z = 0.4; % Damping ratio
dt_k = 700; 

Gdtr = dt_k * tf([2*dt_z*dt_w 0],[1, 2*dt_z*dt_w, dt_w^2]);
% figure(1)
% bode(Gdtr)

figure(2)
bode(sys{7}(1,3) * C2)
set(findobj (gcf, "type", "axes"), "nextplot", "add")
bode(sys{7}(1,3) / (1 - sys{7}(1,3) * Gdtr) * C2)