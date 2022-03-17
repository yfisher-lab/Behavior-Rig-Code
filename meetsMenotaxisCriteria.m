function [MenotaxisBoolean] = meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold)
%Test whether fly is menotaxing or not during a whole trial based on
%velocity and circular standard deviation.
%   Detailed explanation goes here

%% Calculate forward velocity
lowPassFilterCutOff = 25 %Hz; half of avg processing
maxFlyVelocity = 1000 %deg/s
[ballVelocity,accumulatedPositionOut] = ficTracSignalDecoding(ballForwardData,sampleRate,lowPassFilterCutOff,maxFlyVelocity);
forwardVelocity = -1*(ballVelocity);

wantedIndex = find(forwardVelocity > forwardVelocityThreshold);
wantedHeading = ballHeadingData(wantedIndex);


%% Calculate circular standard deviation
circularStDev = circ_std(wantedHeading);
if circularStDev > stDevThreshold %deg
    MenotaxisBoolean = false;
else
    MenotaxisBoolean = true;
end

end