clear all; close all;

% Run this section before you plug in the 808nm laser to ensure that it's
% sending out [0] cmds (to avoid frying the fly).

dq = daq("ni");
addoutput(dq, 'Dev1', 'port0/line0', 'Digital'); 
dq.Rate = 20000;

digCmdsOut = [0];
write(dq, digCmdsOut);
disp('Sending [0]: Laser at lowest power.');


%% Send 0V.

digCmdsOut = [0];
write(dq, digCmdsOut);
disp('Sending [0]');


%% Send 5V.

digCmdsOut = [1];
write(dq, digCmdsOut);
disp('Sending [1]');


%% Generate PWM commands.

% Pulse-width modulation parameters.
freq = 200; % Hz
dutyCyc = 2; % percent, time(on)/(time(on)+time(off))
dur = 30; % seconds
delay = 5; % seconds

% Every cycle occupies this many bins in command output.
cycleBins = (1/freq) * dq.Rate;

% Calculate number of times to repeat pulse seq based on duration of expt.
numReps = round((dur * dq.Rate) / cycleBins);

% Calculate number of bins dedicated to 'on' (1) and 'off' (0).
pulseOnBins = floor(cycleBins * (dutyCyc/100));
pulseOffBins = ceil(cycleBins * ((100-dutyCyc)/100));

% Make matrix of 0 and 1 commands representing one pulse on/off cycle.
pulseCmds = [ones(pulseOnBins,1);...
             zeros(pulseOffBins,1)];

% Create final command output matrix (delay + repeated pulseCmds mat).
digCmdsOut = [zeros(delay * dq.Rate, 1);...
              repmat(pulseCmds, [numReps,1])];

if isempty(find(pulseCmds,1))
    disp('Commands all 0. Pick different dq rate / freq / duty cycle.')
else
    disp('Commands generated.');
end

%% Run PWM.

disp('Start P-W-M.');
readwrite(dq, digCmdsOut);
disp('End P-W-M.');

