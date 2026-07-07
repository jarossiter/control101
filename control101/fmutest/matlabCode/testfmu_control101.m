T2value=200;
out = sim("nonlineartankfmu_control101.slx");
yy=out.simout;
y=yy.signals.values;
t=yy.time;
figure(1); clf reset
subplot(121)
plot(t,y)

y2=sim("fmudemo_vdp_control101.slx");
yy2=get(y2.yout,1);
yy2.Values;
subplot(122)
plot(yy2.Values.Time,yy2.Values.Data)