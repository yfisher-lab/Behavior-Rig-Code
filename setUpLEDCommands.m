function LEDCmdsOut = setUpLEDCommands(LEDParams, dqRate) 
%%
HIGH_VOLTAGE = 5;

stimCycleDur = LEDParams.LEDOnTime + LEDParams.interStimDur;
stimCycleReps = LEDParams.dur/stimCycleDur;

LEDPulse = [HIGH_VOLTAGE * ones(LEDParams.LEDPulseOnTime * dqRate, 1);...
            zeros(LEDParams.LEDPulseOffTime * dqRate, 1)];

pf = LEDParams.LEDOnTime / (LEDParams.LEDPulseOnTime + LEDParams.LEDPulseOffTime);

LEDCmdsOut = repmat(LEDPulse, [pf,1]);

LEDCmdsOut = [LEDCmdsOut; zeros(LEDParams.interStimDur * dqRate, 1)];

%LEDCmdsOut = ...%[zeros(LEDParams.delay * dqRate, 1);...
%              [HIGH_VOLTAGE * ones(LEDParams.LEDOnTime * dqRate, 1);...
%              zeros(LEDParams.interStimDur * dqRate, 1)]; % LED on/off sequence matrix

LEDCmdsOut = [zeros(LEDParams.delay * dqRate, 1);...
              repmat(LEDCmdsOut,[stimCycleReps,1])];

end