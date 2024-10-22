%% Matlab code to define controller transfer functions
%% and calculate parameters for C code
%% DT August 2022


C1 = zpk(-0.07, [0, -2.0], -1);
C2 = zpk(-0.07,[0, -2.0], -1);
target_crossover = 0.8; % rad/s

% Index of switching point between above and below-rated in Bladed output struct
rated_index = 12;

% These indexes have had a wobble during linearisation.
% If the wind speeds either side of them are OK then they can be safely excluded.
excluded = [0];

% gs.M = 1;
% gs.C = 1;

for j = 1:size(linmod.PitchAngles)(1)
    GS_gain(j) = 1 / polyval([gs.M, gs.C], linmod.PitchAngles(j));
end

INCLUDE_CONTROLLERS = 1;

if (1)    
    if (~INCLUDE_CONTROLLERS)
        % Above-rated bode plots
        figure(1)
        for j = rated_index:size(sys)(2)
            disp(j)
            if ~ismember(excluded, j)
                try
                    bode(sys{j}(1,2) * GS_gain(j))
                catch
                    fprintf('Bode failed at index %d\n', j)
                end
                set(findobj (gcf, "type", "axes"), "nextplot", "add")
            end
        end
    else
        figure(2)
        for k = rated_index:size(sys)(2)
            disp(k)
            if ~ismember(excluded, k)
                try
                    bode(sys{k}(1,2) * GS_gain(k) * C1)
                catch
                    fprintf('Bode failed at index %d\n', k)
                end
                set(findobj (gcf, "type", "axes"), "nextplot", "add")
            end
        end
    end

    if (~INCLUDE_CONTROLLERS)
        % Below-rated bode plots
        figure(3)
        for l = 1:rated_index
            disp(l)
            if ~ismember(excluded, l)
                try
                    bode(sys{l}(1,3))
                catch
                    fprintf('Bode failed at index  %d\n', l)
                end
                set(findobj (gcf, "type", "axes"), "nextplot", "add")
            end
        end
    else
        figure(4)
        for m = 1:rated_index
            disp(m)
            if ~ismember(excluded, m)
                try
                    bode(sys{m}(1,3) * C2)
                catch
                    % disp(m)
                    % disp(linmod.Windspeeds(m))
                    fprintf('Bode failed at index  %d\n', m)
                end
                set(findobj (gcf, "type", "axes"), "nextplot", "add")
            end
        end
    end
end

% Split controller transfer functions into inner and outer controllers
[C1z, C1p, C1k]=zpkdata(C1, 'v');
[C2z, C2p, C2k]=zpkdata(C2, 'v');
Ci = zpk(C2z, max(C2p), -100);
Co = zpk([], min(C2p), C2k / -100);

% Calculate switching gains
H=(Co * Ci) / (1 - Ci);
% Ko=abs(dcgain(H));
% dcgain() function returns NaN in octave for some reason so using alternative method below
[Hmag, ~] = bodemag(H);
Ko = abs(Hmag(1));
Kcp = 1 / Ko;
Kp = C1k / C2k;


Cpmax = max(pcoeffs(:,2));
lambda = pcoeffs(find((pcoeffs(:,2) == Cpmax)),1);

R = 90.0/2;
N = 100.5;
Kopt = (0.5 * 1.225 * pi * R^5 * Cpmax) / (lambda^3 * N^3);

WSET = (19 * N) * pi / 30;
W0 = (9 * N) * pi / 30;
DW = WSET - W0;
gls = 946400;
ghs = 0;
B = (gls + N^2 * ghs) / (N^2);
T0 = Kopt * (WSET - DW)^2 - B * (WSET - DW);
T1 = Kopt * WSET^2 - B * WSET;

PSET = 2.5e6;
elec_eff = 0.95;
TSET = (PSET / elec_eff) / WSET;

[c1mag, ~] = bodemag(sys{16}(1,2) * C1 * GS_gain(16), target_crossover);
[c2mag, ~] = bodemag(sys{7}(1,3) * C2, target_crossover);
newC1k = C1k / c1mag
newC2k = C2k / c2mag