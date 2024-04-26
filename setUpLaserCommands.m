function [laserCmdsOut] = setUpLaserCommands(params, dqRate)

% Every cycle occupies this many bins in command output.
cycleBins = (1/params.freq) * dqRate;

% Calculate number of times to repeat pulse seq based on duration of expt.
numReps = round((params.dur * dqRate) / cycleBins);

% Calculate number of bins dedicated to 'on' (1) and 'off' (0).
pulseOnBins = floor(cycleBins * (params.dutyCyc/100));
pulseOffBins = ceil(cycleBins * ((100-params.dutyCyc)/100));

% Make matrix of 0 and 1 commands representing one pulse on/off cycle.
pulseCmds = [ones(pulseOnBins,1);...
             zeros(pulseOffBins,1)];

% Check if pulseCmds are all zeros.
if isempty(find(pulseCmds,1))
    cmdsAllZeroException = MException('Not:Good',...
        'Laser commands all 0: Choose a different dq.Rate/freq/dutyCycle combination.');
    throw(cmdsAllZeroException);
else
    disp('Laser commands generated OK.');
end

% Create final command output matrix (delay + repeated pulseCmds mat).
laserCmdsOut = [zeros(params.delay * dqRate, 1);...
              repmat(pulseCmds, [numReps,1])];

end

