pcoeffs = dlmread('pcoeffs.txt','\t',2,0);

Cpmax = max(pcoeffs(:,2));
lambda = pcoeffs(find((pcoeffs(:,2) == Cpmax)),1);
Ctmax = pcoeffs(find(pcoeffs(:,2) == Cpmax),3);
Cqmax = pcoeffs(find(pcoeffs(:,2) == Cpmax),4);

R = 45;
N = 77.44;
Kopt = (0.5 * 1.225 * pi * R^5 * Cpmax) / (lambda^3 * N^3);