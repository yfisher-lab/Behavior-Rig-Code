clear all;

%% Import file with data to plot
file = 'Menotaxis_220314_trial_25';
importfile(file)


%% Menotaxis test criteria
forwardVelocityThreshold = 6; %deg/sec
stDevThreshold = deg2rad(45);

ballHeadingData = ballData.data.ballHeadingRad;
ballForwardData = ballData.data.Dev1_ai3;
sampleRate = ballData.dqRate;

[menotaxisBoolean,anglePreference,magnitudePreference]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold);


%% Analyze all files in a folder
% [trialFilesList,fullTrialFilesList,fullTrialNumList ] = extractTrialsFromFolder()
% for i = = 1:length(fileList) 