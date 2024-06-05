function [G,a0] = disca0(F,T,FLAG_DELAY)
% DISCA0  Calculate G(s) and a0 from F(s)
%    F(s) may be up to third order
%    T is the time step
%    FLAG_DELAY {1,0} sets whether a time delay, z^-1, should be included in
%    G(s)
%
%    [G,a0] = disca0(F,T,1) calculates G where G(s) = (F(s)-a0)z^-1
%    [G,a0] = disca0(F,T,0) calculates G where G(s) = (F(s)-a0)


if nargin < 2
    T=0.01;
end
if nargin < 3
    FLAG_DELAY=1;
end

[Fn,Fd]=tfdata(F,'v');

if(numel(Fn)==2)
    Fn(3)=Fn(2);
    Fn(2)=Fn(1);
    Fn(1)=0;
end

if(numel(Fd)==2)
    Fd(3)=Fd(2);
    Fd(2)=Fd(1);
    Fd(1)=0;
end

A=Fn(1);
B=Fn(2);
C=Fn(3);
D=Fd(1);
E=Fd(2);
F=Fd(3);

a0=(4*A + 2*T*B + T^2*C)/(4*D + 2*T*E + T^2*F);

if FLAG_DELAY
    GNum1=a0*D-A;
    GNum2=((2*A-2*a0*D)/-T)+((T*C-T*a0*F)/2);
else
    GNum1=A-a0*D;
    GNum2=B-a0*E;
end

GNum3=C-a0*F;
GDen1=D;
GDen2=E;
GDen3=F;
GNum=[GNum1 GNum2 GNum3];
GDen=[GDen1 GDen2 GDen3];
G=tf(GNum,GDen);

end