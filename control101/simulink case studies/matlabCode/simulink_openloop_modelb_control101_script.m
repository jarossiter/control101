% Script file to define parameters required by simulink file 
%
%       simulink_openloop_modelb_control101.slx
%
% then run the file and plot the results

C=6000;  % Maximum engine force on the road
M = 1000; % car mass
B = 500; % Friction
Mg = M*10; % assume gravity = 10

time = [0,1.9,2:0.5:7,8,10]; % times when throttle changes
throttle=[0,0,0:.1:1,1,1]; % values of the throttle
wind = [zeros(1,10),ones(1,5)*5]; % values of the wind
slope = [zeros(1,6),ones(1,9)*0.1]; % values of the slope
throttleprofile=[time;throttle]';
windprofile=[time;wind]';
slopeprofile=[time;slope]';
t_stop=15;         % end time of the simulation

% Simulation
sim("simulink_openloop_modelb_control101.slx");
% Output data is in the structure speedandthrottle
speedandthrottle

% Plotting
figure(2); clf reset
subplot(211)
plot(speedresponses.time,speedresponses.signals.values,'LineWidth',2)
grid
legend('Wind effect','Throttle effect','Slope effect','Total')
title('Speed of car (m/s)')
xlabel('Seconds')

% Input data is in the structure throttlewindslope
subplot(212)
plot(throttlewindslope.time,throttlewindslope.signals.values,'LineWidth',2)
grid
legend('Wind','Throttle','Slope')
title('Input signals')
xlabel('Seconds')

%print(['-ssimulink_openloop_modelb_control101'],'-djpeg',['simulink_openloop_modelb_control101.jpg'])