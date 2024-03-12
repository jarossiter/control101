% Script file to define parameters required by simulink file 
%
%       simulink_openloop_modelc_control101.slx
%
% then run the file and plot the results

C=2000;  % Maximum enginer force on the road
M = 1000; % car mass
B = 500; % Friction
time = [0:30]; % times when throttle changes
throttle=ones(1,31); % values of the throttle
gear = [ones(1,10),ones(1,10)*1.5,ones(1,11)*2];
throttleprofile=[time;throttle]';
Gearprofile = [time;gear]';
t_stop=40;

% Simulation
sim("simulink_openloop_modelc_control101.slx");
% Output data is in the structure speedgearthrottle
speedgearthrottle

% Plotting
figure(3); clf reset
plot(speedgearthrottle.time,speedgearthrottle.signals.values,'LineWidth',2)
grid
legend('Gear','Speed','Throttle')
title('Speed of car (m/s)')
xlabel('Seconds')

% Create a jpg image of the simulink diagram
%print(['-ssimulink_openloop_modelc_control101'],'-djpeg',['simulink_openloop_modelc_control101.jpg'])