
clear all;
% Import file with data to plot
file = 'Menotaxis_220225_trial_1';
importfile(file)

%% Plot data in sec 
figure;
plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballHeadingDeg);
title(file,'Interpreter','none');
xlabel('Time (sec)');
ylabel('Ball Heading (deg)');

figure;
plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballxPosDeg);
title(file,'Interpreter','none');
xlabel('Time (sec)');
ylabel('Ball X-Position (deg)');

figure;
plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballyPosDeg);
title(file,'Interpreter','none');
xlabel('Time (sec)');
ylabel('Ball Y-Position (deg)');

%% Plot data in min
% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballHeadingDeg);
% title(file,'Interpreter','none');
% xlabel('Time (min)');
% ylabel('Ball Heading (deg)');
% 
% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballxPosDeg);
% title(file,'Interpreter','none');
% xlabel('Time (min)');
% ylabel('Ball X-Position (deg)');
% 
% figure;
% plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballyPosDeg);
% title(file,'Interpreter','none');
% xlabel('Time (min)');
% ylabel('Ball Y-Position (deg)');

%% histogram - to check if results are random vs. she's actually menotaxing
figure;
hist.plot = histogram(ballData.data.ballHeadingDeg);
title(file,'Interpreter','none');
xlabel('Ball Heading (deg)');
ylabel('Frequency');

%figure;
%hist.plot = histogram(ballData.data.ballyPosDeg);
%title(file,'Interpreter','none');
%xlabel('Ball Y-Position (deg)');
%ylabel('Frequency');

%figure;
%hist.plot = histogram(ballData.data.ballxPosDeg);
%title(file,'Interpreter','none');
%xlabel('Ball X-Position (deg)');
%ylabel('Frequency');


%% Calculate velocity

%sampleTheta = [0,pi/2,pi,4*pi/3,2*pi,5.2];%for troubleshooting
%t = [1,2,3,4,5,6]
%v = diff(sampleTheta)/diff(t);

pos = ballData.data.ballHeadingDeg;
%time = [];
%for i = 1:length(ballData.data.ballHeadingDeg)
 %   time(i,1) = i;
%end

v = diff(pos);
v = v/ballData.dqRate;
%vTotal = mean(v);

figure;
plot([1:1:length(ballData.data.LEDcommand)-1]/ballData.dqRate ,v);
title(file,'Interpreter','none');

%% create intervals of each min in data

INTERVAL_LENGTH = 60; %seconds
totalNumIntervals = length(ballData.data.ballHeadingDeg)/(ballData.dqRate*INTERVAL_LENGTH);
totalNumIntervals = floor(totalNumIntervals);
figure;

for i = 1:totalNumIntervals
    x = [];
    y = [];
    startInt = [ballData.dqRate *(i-1)*INTERVAL_LENGTH] + 1;
    endInt = i * ballData.dqRate *INTERVAL_LENGTH;
    currMin = ballData.data.ballHeadingRad(startInt:endInt);
    [xMean,yMean] = meanVector (currMin);
    c = compass(xMean,yMean);
    c = compass(0,1,'w')
    hold on;  
end

[xMeanTot,yMeanTot] = meanVector (ballData.data.ballHeadingRad);
c = compass(xMeanTot,yMeanTot,'r');
c.LineWidth = 4;
hold on;

% ax = gca
% ax.YLim = [-1 1]
% ax.XLim = [-1 1]
view(90,90)

title(file,'Interpreter','none');

function [xMean,yMean]= meanVector(data)

for k = 1:length(data)
    theta =data(k);
    vLength =1; % vector size
    [x(k),y(k)] = pol2cart (theta,vLength);
end
xMean = mean(x);
yMean = mean(y);


end







    

