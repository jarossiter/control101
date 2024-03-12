% Script file to define parameters required by simulink file 
%
%       simulink_openloop_model_control101.slx
%
% then run the file and plot the results


C=6000;  % Maximum engine force on the road
M = 1000; % car mass
B = 500; % Friction
time = [0,1.9,2:0.5:7,8,10]; % times when throttle changes
throttle=[0,0,0:.1:1,1,1]; % values of the throttle
throttleprofile=[time;throttle]';
t_stop=15;

% Simulation
sim("simulink_openloop_model_control101.slx");
% Output data is in the structure speedandthrottle
speedandthrottle

% Plotting
figure(1); clf reset
plot(speedandthrottle.time,speedandthrottle.signals.values,'LineWidth',2)
grid
legend('Throttle','Speed')
title('Speed of car (m/s)')
xlabel('Seconds')

% Create a jpg image of the simulink diagram
%print(['-ssimulink_openloop_model_control101'],'-djpeg',['simulink_openloop_model_control101.jpg'])