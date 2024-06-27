function [laserCmdsOut] = setUpLaserCommands(params, dqRate)

% Every cycle occupies this many 'bins' in command output.
cycleBins = (1/params.freq) * dqRate;

% Calculate number of times to repeat pulse seq based on duration of expt.
numReps = round((params.dur * dqRate) / cycleBins);

% Calculate number of bins dedicated to 'on' (0) and 'off' (1).
pulseOnBins = floor(cycleBins * (params.dutyCyc/100));
pulseOffBins = ceil(cycleBins * ((100-params.dutyCyc)/100));

% Make matrix of 0 and 1 commands representing one pulse on/off cycle.
pulseCmds = [zeros(pulseOnBins,1);...
             ones(pulseOffBins,1)];

% Check if pulseCmds are all 1's. 
if isempty(find(pulseCmds == 0))
    cmdsAllOnesException = MException('Not:Good',...
        'Laser commands all [1]: Choose a different dq.Rate/freq/dutyCycle combination.');
    throw(cmdsAllOnesException);
else
    disp('Laser commands generated OK.');
end

% Create final command output matrix (delay + repeated pulseCmds mat).
laserCmdsOut = [ones(params.delay * dqRate, 1);...
              repmat(pulseCmds, [numReps,1])];

end

