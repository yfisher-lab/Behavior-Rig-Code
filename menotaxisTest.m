%% Analyze one file
clear all;

file = 'Menotaxis_220311_trial_3';
importfile(file)

% Menotaxis test criteria
forwardVelocityThreshold = 6; %deg/sec
stDevThreshold = deg2rad(45);

ballHeadingData = ballData.data.ballHeadingRad;
ballForwardData = ballData.data.Dev1_ai3;
sampleRate = ballData.dqRate;

% Menotaxis test
[menotaxisBoolean,anglePreference,magnitudePreference]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold);


%% Analyze all files in a folder
clear all;

[trialFilesList,fullTrialFilesList] = extractTrialsFromFolder()

totalMenotaxisResults = struct();

% fileNames = trialFilesList.name
for i = 1:length(trialFilesList) 
    file = trialFilesList(i).name
    importfile(file)
    % Menotaxis test criteria
    forwardVelocityThreshold = 30; %deg/sec
    stDevThreshold = deg2rad(45);
    ballHeadingData = ballData.data.ballHeadingRad;
    ballForwardData = ballData.data.Dev1_ai3;
    sampleRate = ballData.dqRate;
    % Menotaxis test
    [menotaxisBoolean,anglePreference,magnitudePreference]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold);
    % Save menotaxis results
    totalMenotaxisResults(i).filename = file;
    totalMenotaxisResults(i).menotaxisBoolean = menotaxisBoolean;
    totalMenotaxisResults(i).anglePreference = anglePreference;
    totalMenotaxisResults(i).magnitudePreference = magnitudePreference;
end