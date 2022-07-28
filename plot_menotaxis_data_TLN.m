
clear all;
% Import file with data to plot
file = 'Menotaxis_220329_trial_7';
importfile(file)

%% Plot data in sec 
% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballHeadingDeg);
% title(file,'Interpreter','none');
% xlabel('Time (sec)');
% ylabel('Ball Heading (deg)');
% 
% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballxPosDeg);
% title(file,'Interpreter','none');
% xlabel('Time (sec)');
% ylabel('Ball X-Position (deg)');
% 
% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballyPosDeg);
% title(file,'Interpreter','none');
% xlabel('Time (sec)');
% ylabel('Ball Y-Position (deg)');

%% Plot data in min
figure;
plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballHeadingDeg);
title(file,'Interpreter','none');
xlabel('Time (min)');
ylabel('Ball Heading (deg)');

% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballxPosDeg);
% title(file,'Interpreter','none');
% xlabel('Time (min)');
% ylabel('Ball X-Position (deg)');

figure;
plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballyPosDeg);
title(file,'Interpreter','none');
xlabel('Time (min)');
ylabel('Ball Y-Position (deg)');

%% histogram - to check if results are random vs. she's actually menotaxing
figure;
hist.plot = histogram(ballData.data.ballHeadingDeg);
title(file,'Interpreter','none');
xlabel('Ball Heading (deg)');
ylabel('Frequency');

% figure;
% hist.plot = histogram(ballData.data.ballyPosDeg);
% title(file,'Interpreter','none');
% xlabel('Ball Y-Position (deg)');
% ylabel('Frequency');

%figure;
%hist.plot = histogram(ballData.data.ballxPosDeg);
%title(file,'Interpreter','none');
%xlabel('Ball X-Position (deg)');
%ylabel('Frequency');


%% Calculate forward velocity

lowPassFilterCutOff = 25; %Hz; half of avg processing
maxFlyVelocity = 1000; %deg/s
[ballVelocity,accumulatedPositionOut] = ficTracSignalDecoding(ballData.data.Dev1_ai3,ballData.dqRate,lowPassFilterCutOff,maxFlyVelocity);
forwardVelocity = -1*(ballVelocity);

figure;
plot([1:1:length(ballData.data.ballHeadingDeg)]/ballData.dqRate,forwardVelocity);
title(file,'Interpreter','none');
xlabel('Time')
ylabel('Forward Velocity (deg/s)')

figure;
hist.plot = histogram(forwardVelocity);
title(file,'Interpreter','none');
xlabel('Forward Velocity (deg/s)');
ylabel('Frequency');

% (Sanity check) Plot Y_Pos and Forward Velocity
% figure;
% x = [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate;
% subplot(2,1,1)
% plot(x,ballData.data.ballyPosDeg);
% subplot(2,1,2)
% plot(x,forwardVelocity)

%% Transform heading values so vector direction is the position of the cue 
% relative to the fly if 180 deg is the cue directly in front
transformedHeading = -1*(ballData.data.ballHeadingRad);

%% Plot heading vector for a defined interval on a compass plot

INTERVAL_LENGTH = 60; %seconds
totalNumIntervals = length(ballData.data.ballHeadingDeg)/(ballData.dqRate*INTERVAL_LENGTH);
totalNumIntervals = floor(totalNumIntervals);
figure;

for i = 1:totalNumIntervals
    x = [];
    y = [];
    startInt = [ballData.dqRate *(i-1)*INTERVAL_LENGTH] + 1;
    endInt = i * ballData.dqRate *INTERVAL_LENGTH;
    %currHeading = ballData.data.ballHeadingRad(startInt:endInt);
    currHeading = transformedHeading(startInt:endInt);
    [xMean,yMean] = meanVector (currHeading); 
    % plot on compass plot
    c = compass(xMean,yMean);
    % plot arrows in a color gradient that changes over time
    firstColor = [19, 16, 92]/92;
    lastColor = [110,219,250]/250;
    lineColors = [linspace(firstColor(1),lastColor(1),totalNumIntervals)', linspace(firstColor(2),lastColor(2),totalNumIntervals)', linspace(firstColor(3),lastColor(3),totalNumIntervals)'];
    c.Color = lineColors(i,:)
    c.LineWidth = 2
    % invisible vector for axes = 1
    c = compass(0,1,'w')
    hold on;    
end

% plot total mean vector with a thick red line
[xMeanTot,yMeanTot] = meanVector (transformedHeading);
c = compass(xMeanTot,yMeanTot);
c.Color = [1, 0, 0]
c.LineWidth = 4;

title(file,'Interpreter','none');
subtitle('Avg Heading/min')
view(90,90);

%% Plot heading vector for a defined interval on a compass plot and exclude 
% values where the fly is moving slower than a defined threshold

VELOCITY_THRESHOLD = 30 %deg/sec
INTERVAL_LENGTH = 60; %seconds

totalNumIntervals = length(ballData.data.ballHeadingDeg)/(ballData.dqRate*INTERVAL_LENGTH);
totalNumIntervals = floor(totalNumIntervals);
figure;

for i = 1:totalNumIntervals
    x = [];
    y = [];
    startInt = [ballData.dqRate *(i-1)*INTERVAL_LENGTH] + 1;
    endInt = i * ballData.dqRate *INTERVAL_LENGTH;
    %currHeading = ballData.data.ballHeadingRad(startInt:endInt);
    currHeading = transformedHeading(startInt:endInt);
    % exclude values below a defined velocity
    currVelocity = forwardVelocity(startInt:endInt);
    wantedIndex = find(currVelocity > VELOCITY_THRESHOLD);
    currWantedHeading = currHeading(wantedIndex);
    [xMean,yMean] = meanVector(currWantedHeading); 
    % plot on compass plot
    c = compass(xMean,yMean);
    % plot arrows in a color gradient that changes over time
    firstColor = [19, 16, 92]/92;
    lastColor = [110,219,250]/250;
    lineColors = [linspace(firstColor(1),lastColor(1),totalNumIntervals)', linspace(firstColor(2),lastColor(2),totalNumIntervals)', linspace(firstColor(3),lastColor(3),totalNumIntervals)'];
    c.Color = lineColors(i,:)
    c.LineWidth = 2
    % invisible vector for axes = 1
    c = compass(0,1,'w')
    hold on;    
end

% plot total mean vector with a thick red line
wantedIndex = find(forwardVelocity > VELOCITY_THRESHOLD);
wantedHeading = transformedHeading(wantedIndex);
[xMeanTot,yMeanTot] = meanVector (wantedHeading);
c= compass(xMeanTot,yMeanTot,'r');
c.LineWidth = 4;

% compass plot parameters
title(file,'Interpreter','none');
subtitle(['Avg Heading/min excluding velocity < ', num2str(VELOCITY_THRESHOLD),'deg/sec'])
view(90,90);

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



    

