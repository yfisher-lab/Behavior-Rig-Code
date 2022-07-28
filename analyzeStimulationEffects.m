
clear all;
% Import file with data to plot
file = 'Menotaxis_220331_trial_7';
importfile(file);

% Find LED on timepoints
stimulusDiff = diff(ballData.data.LEDcommand);
[peaks,stimulusIndex] = findpeaks(stimulusDiff);
stimulus = stimulusIndex + 1;

% Define intervals around LED stimulus
startInterval = stimulusIndex - (ballData.dqRate*ballData.LEDParams.baselineTime) + 1;
endInterval = stimulusIndex + (ballData.dqRate*(ballData.LEDParams.LEDonTime+ballData.LEDParams.afterTime));


%% Changes in forward velocity due to stimulus
lowPassFilterCutOff = 25; %Hz; half of avg processing
maxFlyVelocity = 1000; %deg/s
[ballVelocity,accumulatedPositionOut] = ficTracSignalDecoding(ballData.data.Dev1_ai3,ballData.dqRate,lowPassFilterCutOff,maxFlyVelocity);
forwardVelocity = -1*(ballVelocity);

% Create matrix with forward velocity data during intervals around LED
% stimulus
stimulusData = [];
for i = 1:length(stimulusIndex)
    stimulusData(i,:) = forwardVelocity(startInterval(i):endInterval(i));
end

% Plot forward velocity
stimulusPlot = transpose(stimulusData);
figure;
plot([1:1:length(stimulusData)]/ballData.dqRate,stimulusPlot);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on')
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Forward Velocity (deg/s)')

% Plot mean
meanStimulusData = mean(stimulusData);
figure;
plot([1:1:length(stimulusData)]/ballData.dqRate,meanStimulusData);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on');
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Mean Forward Velocity (deg/s)')


%% Plot heading relative to preferred cue position
VELOCITY_THRESHOLD = 30 %deg/sec

transformedHeading = -1*(ballData.data.ballHeadingRad);
wantedIndex = find(forwardVelocity > VELOCITY_THRESHOLD);
wantedHeading = transformedHeading(wantedIndex);
[xMeanTot,yMeanTot] = meanVector (wantedHeading);
[anglePrefRad, magnitudePreference] =cart2pol(xMeanTot,yMeanTot);

headingRelativeToAnglePref = [];
for i = 1:length(transformedHeading)
    headingRelativeToAnglePref(i,:) = circ_dist(transformedHeading(i),anglePrefRad);
end

stimulusData = [];
for i = 1:length(stimulusIndex)
    stimulusData(i,:) = headingRelativeToAnglePref(startInterval(i):endInterval(i));
end

figure;
plot([1:1:length(transformedHeading)]/ballData.dqRate,headingRelativeToAnglePref);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on')
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Heading Relative to Preferred Angle (rad)')

figure;
meanRelativeHeading = mean(stimulusData);
plot([1:1:length(stimulusData)]/ballData.dqRate,meanRelativeHeading);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on')
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Mean Heading Relative to Preferred Angle (rad)')

%% Changes in rotational velocity due to stimulus
lowPassFilterCutOff = 25; %Hz; half of avg processing
maxFlyVelocity = 1000; %deg/s
[ballVelocity,accumulatedPositionOut] = ficTracSignalDecoding(ballData.data.Dev1_ai1,ballData.dqRate,lowPassFilterCutOff,maxFlyVelocity);
rotationalVelocity = -1*(ballVelocity);

% Create matrix with forward velocity data during intervals around LED
% stimulus
stimulusData = [];
for i = 1:length(stimulusIndex)
    stimulusData(i,:) = rotationalVelocity(startInterval(i):endInterval(i));
end

% Plot rotational velocity
stimulusPlot = transpose(stimulusData);
figure;
plot([1:1:length(stimulusData)]/ballData.dqRate,stimulusPlot);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on')
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Rotational Velocity (deg/s)')

% Plot mean
meanStimulusData = mean(stimulusData);
figure;
plot([1:1:length(stimulusData)]/ballData.dqRate,meanStimulusData);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on');
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Mean Rotational Velocity (deg/s)')

% Plot mean of absolute values
absStimulusData = abs(stimulusData);
meanAbsStimulusData = mean(absStimulusData);
figure;
plot([1:1:length(stimulusData)]/ballData.dqRate,meanAbsStimulusData);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on');
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Mean Absolute Rotational Velocity (deg/s)')

% Plot standard deviation
stDevStimulusData = std(stimulusData);
figure;
plot([1:1:length(stimulusData)]/ballData.dqRate,stDevStimulusData);
xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on');
title(file,'Interpreter','none');
xlabel('Time (sec)')
ylabel('Standard Deviation Rotational Velocity (deg/s)')

%% Analyze multiple files in folder
clear all;
[trialFilesList,fullTrialFilesList] = extractTrialsFromFolder()

% fileNames = trialFilesList.name
for i = 1:length(trialFilesList) 
    file = trialFilesList(i).name
    importfile(file)
    % Find LED on timepoints
    stimulusDiff = diff(ballData.data.LEDcommand);
    [peaks,stimulusIndex] = findpeaks(stimulusDiff);
    % Define intervals around LED stimulus
    startInterval = stimulusIndex - (ballData.dqRate*ballData.LEDParams.baselineTime) + 1;
    endInterval = stimulusIndex + (ballData.dqRate*(ballData.LEDParams.LEDonTime+ballData.LEDParams.afterTime));
    % Changes in forward velocity due to stimulus
    lowPassFilterCutOff = 25; %Hz; half of avg processing
    maxFlyVelocity = 1000; %deg/s
    [ballVelocity,accumulatedPositionOut] = ficTracSignalDecoding(ballData.data.Dev1_ai3,ballData.dqRate,lowPassFilterCutOff,maxFlyVelocity);
    forwardVelocity = -1*(ballVelocity);
    % Create matrix with forward velocity data during intervals around LED
    % stimulus
    stimulusData = [];
    for i = 1:length(stimulusIndex)
        stimulusData(i,:) = forwardVelocity(startInterval(i):endInterval(i));
    end
    meanStimulusData = mean(stimulusData);
    figure;
    plot([1:1:length(stimulusData)]/ballData.dqRate,meanStimulusData);
    xline(stimulusIndex(1)/ballData.dqRate,'-b','LED on');
    title(file,'Interpreter','none');
    xlabel('Time (sec)')
    ylabel('Mean Forward Velocity (deg/s)')
    hold on;
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