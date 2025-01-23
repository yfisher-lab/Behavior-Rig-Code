clear all; close all;
% Run this section before you plug in the laser to ensure that it's
% sending out [1] cmds (to avoid frying the fly).

dq = daq("ni");
addoutput(dq, 'Dev1', 'port0/line0', 'Digital');
addinput(dq,"Dev1","ai0","Voltage");
dq.Rate = 10000;

digCmdsOut = [1];
write(dq, digCmdsOut);
disp('Sending [1]: Laser off.');

%% Send 0V.

digCmdsOut = [0];
write(dq, digCmdsOut);
disp('Sending [0]: Laser on.');

%% Send 5V.

digCmdsOut = [1];
write(dq, digCmdsOut);
disp('Sending [1]: Laser off.');

%% Generate PWM commands.

% Pulse-width modulation parameters.
params.freq = 200; % Hz
params.dutyCyc = 2; % percent, time(on)/(time(on)+time(off))
params.dur = 60; % seconds
params.delay = 0; % seconds

digCmdsOut = setUpLaserCommands(params, dq.Rate);

%% Run PWM.

disp('Start P-W-M.');
readwrite(dq, digCmdsOut);
disp('End P-W-M.');
