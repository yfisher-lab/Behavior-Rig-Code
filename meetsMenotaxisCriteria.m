function [menotaxisBoolean, anglePreference, magnitudePreference] = meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold)
%Test whether fly is menotaxing or not during a whole trial based on
%velocity and circular standard deviation.
%   Detailed explanation goes here

%% Calculate forward velocity
lowPassFilterCutOff = 25 %Hz; half of avg processing speed
maxFlyVelocity = 1000 %deg/s
[ballVelocity,accumulatedPositionOut] = ficTracSignalDecoding(ballForwardData,sampleRate,lowPassFilterCutOff,maxFlyVelocity);
forwardVelocity = -1*(ballVelocity);

wantedIndex = find(forwardVelocity > forwardVelocityThreshold);
wantedHeading = ballHeadingData(wantedIndex);
transformedWantedHeading = -1*(wantedHeading);


%% Use circular standard deviation to determine whether fly is menotaxing
circularStDev = circ_std(wantedHeading);
if circularStDev > stDevThreshold %deg
    menotaxisBoolean = false;
    anglePreference = false;
    magnitudePreference = false;
else
    menotaxisBoolean = true;
    [xMean,yMean] = meanVector (transformedWantedHeading);
    [anglePrefRad, magnitudePreference] =cart2pol(xMean,yMean);
    anglePreference = rad2deg(anglePrefRad)

%     figure;
%     compass(0,1,'w');
%     hold on;
%     compass(xMean,yMean,'r');
%     view(90,90)
end

%% functions

function [xMean,yMean]= meanVector(data)

for k = 1:length(data)
    theta =data(k);
    vLength =1; % vector size
    [x(k),y(k)] = pol2cart (theta,vLength);
end
xMean = mean(x);
yMean = mean(y);

end

end