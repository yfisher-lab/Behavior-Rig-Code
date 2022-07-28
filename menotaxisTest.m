%% Analyze one file
clear all;

file = 'Menotaxis_220329_trial_7';
importfile(file)

% Menotaxis test criteria
forwardVelocityThreshold = 30; %deg/sec
stDevLimit = deg2rad(60); %radians
dataThreshold = 25 %percent of data must be used

ballHeadingData = ballData.data.ballHeadingRad;
ballForwardData = ballData.data.Dev1_ai3;
sampleRate = ballData.dqRate;

% Menotaxis test
[totalMenotaxisResults,menotaxisBoolean,anglePreference,magnitudePreference,proportionDataUsed,circStDev,averageVelocity]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevLimit,dataThreshold);

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
    stDevLimit = deg2rad(60); %radians
    ballHeadingData = ballData.data.ballHeadingRad;
    ballForwardData = ballData.data.Dev1_ai3;
    sampleRate = ballData.dqRate;
    % Menotaxis test
    [menotaxisResults,menotaxisBoolean,anglePreference,magnitudePreference,proportionDataUsed,circStDev,averageVelocity]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevLimit);
    % Save menotaxis results
    totalMenotaxisResults(i).filename = file;
    totalMenotaxisResults(i).menotaxisBoolean = menotaxisBoolean;
    totalMenotaxisResults(i).anglePreference = anglePreference;
    totalMenotaxisResults(i).magnitudePreference = magnitudePreference;
    totalMenotaxisResults(i).proportionDataUsed = proportionDataUsed;
    totalMenotaxisResults(i).circStDev = circStDev;
    totalMenotaxisResults(i).avgVelocity = averageVelocity
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


%% Analyze >10 min long trials in 10 min increments
clear all;

file = 'Menotaxis_220404_trial_8';
importfile(file)

INTERVAL_LENGTH = 600; %seconds
totalNumIntervals = length(ballData.data.ballHeadingDeg)/(ballData.dqRate*INTERVAL_LENGTH);
totalNumIntervals = floor(totalNumIntervals);

totalMenotaxisResults = struct();

for i = 1:totalNumIntervals
    startInt = [ballData.dqRate *(i-1)*INTERVAL_LENGTH] + 1;
    endInt = i * ballData.dqRate *INTERVAL_LENGTH;
    % Menotaxis test criteria
    forwardVelocityThreshold = 30; %deg/sec
    stDevLimit = deg2rad(60);
    ballHeadingData = ballData.data.ballHeadingRad(startInt:endInt);
    ballForwardData = ballData.data.Dev1_ai3(startInt:endInt);
    sampleRate = ballData.dqRate;
    % Menotaxis test
    [menotaxisResults,menotaxisBoolean,anglePreference,magnitudePreference,proportionDataUsed,circStDev,averageVelocity]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevLimit);
    % Save menotaxis results
    if length(ballData.data.LEDcommand)/(ballData.dqRate) > INTERVAL_LENGTH
        totalMenotaxisResults(i).filename = [file,'_',num2str(0+i)];
    end
    totalMenotaxisResults(i).menotaxisBoolean = menotaxisBoolean;
    totalMenotaxisResults(i).anglePreference = anglePreference;
    totalMenotaxisResults(i).magnitudePreference = magnitudePreference;
    totalMenotaxisResults(i).proportionDataUsed = proportionDataUsed;
    totalMenotaxisResults(i).circStDev = circStDev;
    totalMenotaxisResults(i).avgVelocity = averageVelocity;
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


%% Analyze all files in folder and split files >10 min into 10 min increments
% clear all;
% 
% [trialFilesList,fullTrialFilesList] = extractTrialsFromFolder()
% 
% INTERVAL_LENGTH = 600; %seconds
% totalNumIntervals = length(ballData.data.ballHeadingDeg)/(ballData.dqRate*INTERVAL_LENGTH);
% totalNumIntervals = floor(totalNumIntervals);
% 
% totalMenotaxisResults = struct();
% 
% for i = 1:totalNumIntervals
%     startInt = [ballData.dqRate *(i-1)*INTERVAL_LENGTH] + 1;
%     endInt = i * ballData.dqRate *INTERVAL_LENGTH;
%     % Menotaxis test criteria
%     forwardVelocityThreshold = 30; %deg/sec
%     stDevLimit = deg2rad(60);
%     ballHeadingData = ballData.data.ballHeadingRad(startInt:endInt);
%     ballForwardData = ballData.data.Dev1_ai3(startInt:endInt);
%     sampleRate = ballData.dqRate;
%     % Menotaxis test
%     [menotaxisResults,menotaxisBoolean,anglePreference,magnitudePreference,proportionDataUsed,circStDev,averageVelocity]=meetsMenotaxisCriteria(ballHeadingData,ballForwardData,sampleRate,forwardVelocityThreshold,stDevLimit);
%     % Save menotaxis results
%     if length(ballData.data.LEDcommand)/(ballData.dqRate) > INTERVAL_LENGTH
%         totalMenotaxisResults(i).filename = [file,'_',num2str(0+i)];
%     else
%         totalMenotaxisResults(i).filename = file
%     end
%     totalMenotaxisResults(i).menotaxisBoolean = menotaxisBoolean;
%     totalMenotaxisResults(i).anglePreference = anglePreference;
%     totalMenotaxisResults(i).magnitudePreference = magnitudePreference;
%     totalMenotaxisResults(i).proportionDataUsed = proportionDataUsed;
%     totalMenotaxisResults(i).circStDev = circStDev;
%     totalMenotaxisResults(i).avgVelocity = averageVelocity;
%     if isfield(ballData,'panelParams')
%         totalMenotaxisResults(i).cuePosition = ballData.panelParams.initialPosition;
%     else
%         totalMenotaxisResults(i).cuePosition = 'none'
%     end
%     if isfield(ballData,'LEDParams')
%         totalMenotaxisResults(i).LED = 'ON';
%     else
%         totalMenotaxisResults(i).LED = 'OFF';
%     end
%     totalMenotaxisResults(i).duration = length(ballData.data.LEDcommand)/(60*ballData.dqRate); %min
% end