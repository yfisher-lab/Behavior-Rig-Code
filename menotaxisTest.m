clear all;
% Import file with data to plot
file = 'Menotaxis_220314_trial_25';
importfile(file)

forwardVelocityThreshold = 6; %deg/sec
stDevThreshold = deg2rad(45);

ballHeadingData = ballData.data.ballHeadingRad;
ballForwardData = ballData.data.Dev1_ai3;
sampleRate = ballData.dqRate;

[MenotaxisBoolean]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold);