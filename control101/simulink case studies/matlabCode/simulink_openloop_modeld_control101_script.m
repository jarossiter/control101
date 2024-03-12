% Script file to define parameters required by simulink file 
%
%       simulink_openloop_modeld_control101.slx
%
% then run the file and plot the results

C=1000;  % Maximum engine force on the road
M = 1000; % car mass
B = 500; % Friction
time = [0:30]; % times when throttle changes
throttle = [ones(1,6)*0.1,ones(1,10)*.5,ones(1,6),ones(1,9)*0.6]; % values of the throttle
gear = [ones(1,10),ones(1,10)*1,ones(1,11)*1.5];  % Values of gain due to gearing
throttleprofile=[time;throttle]';
Gearprofile = [time;gear]';
ratemax = 0.1; % rate limits on change of throttle
ratemin = -0.1;
t_stop=40;

% Simulation
sim("simulink_openloop_modeld_control101.slx");
% Output data is in the structure speedgearthrottle
speedgearthrottle

% Plotting
figure(4); clf reset
plot(speedgearthrottle.time,speedgearthrottle.signals.values,'LineWidth',2)
grid
legend('Gear','Speed','Actual Throttle','Throttle demand')
title('Speed of car (m/s)')
xlabel('Seconds')

% Create a jpg image of the simulink diagram
%print(['-ssimulink_openloop_modeld_control101'],'-djpeg',['simulink_openloop_modeld_control101.jpg'])