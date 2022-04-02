%% Analyze one file
clear all;

file = 'Menotaxis_220331_trial_11';
importfile(file)

% Menotaxis test criteria
forwardVelocityThreshold = 30; %deg/sec
stDevThreshold = deg2rad(45);

ballHeadingData = ballData.data.ballHeadingRad;
ballForwardData = ballData.data.Dev1_ai3;
sampleRate = ballData.dqRate;

% Menotaxis test
[totalMenotaxisResults,menotaxisBoolean,anglePreference,magnitudePreference,proportionDataUsed,circStDev]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold);

totalMenotaxisResults.fileName = file;
totalMenotaxisResults.cuePosition = ballData.panelParams.initialPosition;
if isfield(ballData,'LEDParams')
    totalMenotaxisResults.LED = 'ON';
else
    totalMenotaxisResults.LED = 'OFF';
end
totalMenotaxisResults.durationMinutes = length(ballData.data.LEDcommand)/(60*ballData.dqRate); %min

% Save results in excel
% trialResults = struct2table(menotaxisResults)
% saveFileName = ['C:\Users\fisherlab\Dropbox\Data\TLN\Menotaxis\Results\',file,'_results.xlsx']
% writetable (trialResults,saveFileName)

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
    stDevThreshold = deg2rad(90);
    ballHeadingData = ballData.data.ballHeadingRad;
    ballForwardData = ballData.data.Dev1_ai3;
    sampleRate = ballData.dqRate;
    % Menotaxis test
    [menotaxisResults,menotaxisBoolean,anglePreference,magnitudePreference,proportionDataUsed,circStDev]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevThreshold);
    % Save menotaxis results
    totalMenotaxisResults(i).filename = file;
    totalMenotaxisResults(i).menotaxisBoolean = menotaxisBoolean;
    totalMenotaxisResults(i).anglePreference = anglePreference;
    totalMenotaxisResults(i).magnitudePreference = magnitudePreference;
    totalMenotaxisResults(i).proportionDataUsed = proportionDataUsed;
    totalMenotaxisResults(i).circStDev = circStDev;
    if isfield(ballData,'panelParams')
        totalMenotaxisResults(i).cuePosition = ballData.panelParams.initialPosition;
    else
        totalMenotaxisResults(i).cuePosition = 'none'
    end
    if isfield(ballData,'LEDParams')
        totalMenotaxisResults(i).LED = 'ON';
    else
        totalMenotaxisResults(i).LED = 'OFF';
    end
    totalMenotaxisResults(i).duration = length(ballData.data.LEDcommand)/(60*ballData.dqRate); %min
end

% Export results to excel
trialResults = struct2table(totalMenotaxisResults)
saveFileName = ['C:\Users\fisherlab\Dropbox\Data\TLN\Menotaxis\Results\',datestr(now,'yymmdd'),'_all_trial_results.xlsx']
writetable (trialResults,saveFileName)