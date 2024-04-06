clear all; close all;

% DAQ stuff.
dq = daq("ni");
addinput(dq, 'Dev1', 'ai1', 'Voltage');
addoutput(dq, 'Dev1', 'port0/line1', 'Digital'); 
dq.Rate = 5000;

%% Send 0V.

digCmdsOut = [0];
write(dq, digCmdsOut);


%% Send 5V.

digCmdsOut = [1];
write(dq, digCmdsOut);


%% PWM.

% Pulse-width modulation parameters.
freq = 500; % Hz
dutyCyc = 85; % percent, time(on)/(time(on)+time(off))
dur = 15; % seconds
delay = 5; % seconds

% Every cycle occupies this many bins in command output.
cycleBins = (1/freq) * dq.Rate;

% Calculate number of times to repeat pulse seq based on duration of expt.
numReps = (dur * dq.Rate) / cycleBins;

% Calculate number of bins dedicated to 'on' (1) and 'off' (0).
pulseOnBins = floor(cycleBins * (dutyCyc/100));
pulseOffBins = ceil(cycleBins * ((100-dutyCyc)/100));

% Make matrix of 0 and 1 commands representing one pulse on/off cycle.
pulseCmds = [ones(pulseOnBins,1);...
             zeros(pulseOffBins,1)];

% Create final command output matrix (delay + repeated pulseCmds mat).
digCmdsOut = [zeros(delay * dq.Rate, 1);...
              repmat(pulseCmds, [numReps,1])];

disp('Start P-W-M.');
readwrite(dq, digCmdsOut);
disp('End P-W-M.');

