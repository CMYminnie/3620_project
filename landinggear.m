aftcg = 16.5099;
fwdcg = 15.4986;
main = 17.8;
nose = 4.5;
Ma = main - aftcg;
Mf = main - fwdcg;
Na = aftcg - nose;
Nf = fwdcg - nose;
B = main - nose;
x1 = Ma/B;
%if x1 > 0.05
%    disp("x1 True")
%end
x2 = Mf/B;
%if x2 < 0.2
%    disp("x2 True")
%end
MTOW = 33614.1;
loadmax_main = MTOW*Na/B;
mainpercent = loadmax_main / MTOW *100
loadmax_nose = MTOW*Mf/B;
nosepercent = loadmax_nose / MTOW *100;
loadmin_nose = MTOW*Ma/B;
nosepercentmin = loadmin_nose / MTOW *100


mainnum = 4;
nosenum = 2;
Wwmain = loadmax_main / mainnum
Wwnose = loadmax_nose / nosenum
maindia = 5.3 * Wwmain ^0.315;
mainwidth = 0.39 * Wwmain ^0.48;

%KEbrake = 0.5*Wland / 9.81 * Vstall;

%assume tip back angle phine be 25deg, CG height is 1m from belly
H1 = (main - aftcg)/tand(25);
H2 = H1 - 1

%assume tip over angle psi be 50deg
x = asind(H1 / (tand(50) * fwdcg));
MW = main * tand(x)

%find pheta, gear and tail 
tailstart = 32.98 - 8.99;
pheta = atand(H2/(tailstart-main))

%find angle between gear and wingtip
span1h = 4.937 * tand(5);
engineh = span1h + H2 - 0.2478 - 1.346
omega = atand(engineh/(4.937 - MW))

dynbreakload = 0.31*MTOW*H1/B

Vstall = 62.8;
Wland1 = 28727.53591;
Wland2 = 24551.34362;
KEbrake1 = 0.5*Wland1/9.81*Vstall^2
KEbrake2 = 0.5*Wland2/9.81*Vstall^2
