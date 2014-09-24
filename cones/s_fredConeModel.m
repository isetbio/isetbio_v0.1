%%
sigma = 100;			% rhodopsin activity decay rate constant (1/sec)
phi = 50;				% phosphodiesterase activity decay rate constant (1/sec)
eta = 100;				% phosphodiesterase activation rate constant (1/sec)
r(1) = 0;				% initial condition for r
p(1) = eta/phi;			% initial condition for p
TimeStep = 0.001;		% time step 
gdark = 35;				% concentration of cGMP in darkness
cgmp2cur = 10e-3;		% constant relating cGMP to current
cdark = 0.5;			% dark calcium concentration
beta = 50;				% rate constant for calcium removal in 1/sec
betaSlow = 2;
hillcoef = 4;			% cooperativity
hillaffinity = 0.35;		% affinity
NumPts = 800;
StmPts = 400;
StmAmp = 1000;

clear g s c p cslow;
cur2ca = beta * cdark / (cgmp2cur * gdark^3);				% get q using steady state
smax = eta/phi * gdark * (1 + (cdark / hillaffinity)^hillcoef);		% get smax using steady state
tme = 1:NumPts;
tme = tme * TimeStep;

% initial conditions
g(1) = gdark;
s(1) = gdark * eta/phi;		
c(1) = cdark;
p(1) = eta/phi;
cslow(1) = cdark;


%%
% adaptation kinetics

clear Stm;
StepAmp = 30000;
FlashAmp = 50000;
NumPts = 3000;
Stm(1:1000) = 0;
Stm(1001:2000) = StepAmp;
Stm(2001:3000) = 0;
Stm(800) = FlashAmp;
Stm(1200) = FlashAmp;
Stm(1600) = FlashAmp;
Stm(2200) = FlashAmp;
Stm(2600) = FlashAmp;


%%
% inc/dec asymmetry
clear Stm;
MeanAmp = 10000;
StepAmp = 10000;
NumPts = 1000;
Stm(1:NumPts) = MeanAmp;
% Stm(NumPts/2:NumPts/2+500) = MeanAmp - StepAmp;
% Stm(3*NumPts/4:3*NumPts/4+500) = MeanAmp + StepAmp;

%%
tme = 1:NumPts;
clear g s c p cslow;
g(1) = gdark;
s(1) = gdark * eta/phi;		
c(1) = cdark;
p(1) = eta/phi;
cslow(1) = cdark;

% solve difference equations
for pnt = 2:NumPts
    r(pnt) = r(pnt-1) + TimeStep * (-sigma * r(pnt-1) + Stm(pnt));
	p(pnt) = p(pnt-1) + TimeStep * (r(pnt-1) + eta - phi * p(pnt-1));
	c(pnt) = c(pnt-1) + TimeStep * (cur2ca * 2* cgmp2cur * g(pnt-1)^3/(1+cslow(pnt-1)/cdark) - beta * c(pnt-1));
	cslow(pnt) = cslow(pnt-1) - TimeStep * (betaSlow * (cslow(pnt-1)-c(pnt-1)));
	s(pnt) = smax / (1 + (c(pnt) / hillaffinity)^hillcoef);
	g(pnt) = g(pnt-1) + TimeStep * (s(pnt-1) - p(pnt-1) * g(pnt-1));
end
% determine current change
cur = -2 * cgmp2cur * g.^3 * 1 ./ (1 + cslow ./ cdark);

% plot current, pde, synthesis, cGMP and calcium
figure(1); clf;
subplot(6, 1, 1);
plot(tme, cur);
xlabel('time (sec)');
ylabel('current');
subplot(6, 1, 2);
plot(tme, p);
xlabel('time (sec)');
ylabel('pde activity');
subplot(6, 1, 3);
plot(tme, s);
xlabel('time (sec)');
ylabel('synthesis rate');
subplot(6, 1, 4);
plot(tme, g);
xlabel('time (sec)');
ylabel('[cGMP]');
subplot(6, 1, 5) 
plot(tme, c)
xlabel('time (sec)');
ylabel('[calcium]');
subplot(6, 1, 6) 
plot(tme, cslow)
xlabel('time (sec)');
ylabel('[calcium slow]');

figure(2);clf
% plot(cur(5000:length(cur)) - cur(1000)); hold on
% plot(Resp - Resp(1000), 'r');

% plot(tme,BaselineSubtraction(cur,8000,9000),'r','LineWidth',2);
% hold on
% plot(tme,BaselineSubtraction(Resp,8000,9000),'k')
% hold off

plot(tme,(cur))
% hold on
% plot(normalize(Resp))
% hold off
% 
% cur = cur - cur(NumPts/2);
% plot(-cur(NumPts/2:NumPts/2+800)); hold on
% cur = cur - cur(3*NumPts/4);
% plot(cur(3*NumPts/4:3*NumPts/4+800), 'r');


figure(3)
plot(tme,Stm)
%%
% solve difference equations for step or pulse
StmPts = 5;
StmAmp = 1000;
NumPts = 800;
tme = 1:NumPts;

clear g s c p cslow;
g(1) = gdark;
s(1) = gdark * eta/phi;		
c(1) = cdark;
p(1) = eta/phi;
cslow(1) = cdark;

for pnt = 2:NumPts
	if (pnt <= NumPts/4)
        r(pnt) = 0;
    end
    if ((pnt > NumPts/4) && (pnt < (NumPts/4+StmPts)))
        r(pnt) = r(pnt-1) + TimeStep * (-sigma * r(pnt-1) + StmAmp);
    end
    if (pnt >= (NumPts/4+StmPts))
        r(pnt) = r(pnt-1) + TimeStep * (-sigma * r(pnt-1));
    end
	p(pnt) = p(pnt-1) + TimeStep * (r(pnt-1) + eta - phi * p(pnt-1));
	c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^3 - beta * c(pnt-1));
	cslow(pnt) = cslow(pnt-1) - TimeStep * (betaSlow * (cslow(pnt-1)-c(pnt-1)));
	s(pnt) = smax / (1 + (c(pnt) / hillaffinity)^hillcoef);
	g(pnt) = g(pnt-1) + TimeStep * (s(pnt-1) - p(pnt-1) * g(pnt-1));
end
% determine current change
cur = -cgmp2cur * g.^3 ./ (1 + cslow ./ cdark);

% plot current, pde, synthesis, cGMP and calcium
figure(1); clf;
subplot(5, 1, 1);
plot(tme, p);
xlabel('time (sec)');
ylabel('pde activity');
subplot(5, 1, 2);
plot(tme, s);
xlabel('time (sec)');
ylabel('synthesis rate');
subplot(5, 1, 3);
plot(tme, g);
xlabel('time (sec)');
ylabel('[cGMP]');
subplot(5, 1, 4) 
plot(tme, c)
xlabel('time (sec)');
ylabel('[calcium]');
subplot(5, 1, 5) 
plot(tme, cslow)
xlabel('time (sec)');
ylabel('[calcium slow]');

figure(2); clf;
plot(cur);
