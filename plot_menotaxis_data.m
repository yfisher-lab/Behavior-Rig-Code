%% Plot data
clear all;
% Import file with data to plot
importfile('Menotaxis_220208_trial_1') 

%% Plot data
figure;
plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.ballHeadingDeg);
%hold on;
figure;
plot( [1:1:length(ballData.data.LEDcommand)]/ballData.dqRate ,ballData.data.x_posDeg);

%% histogram - to check if results are random vs. she's actually menotaxing
figure;
hist.plot = histogram(ballData.data.ballHeadingDeg);

% Polar plot of fly heading

%% Calculate velocity
sampleTheta = [0,pi/2,pi,4*pi/3,2*pi,5.2]; %for troubleshooting
pos = sampleTheta %ballHeading ;
t = length(sampleTheta); %length of ball heading ;
v = zeros(length(t)-1,1) ;
for i = 1:length(t)-1
    v(i) = (pos(i+1)-pos(i))/(t(i+1)-t(i));
end


%vTotal = sum(v)/length(v);
%vTotal = mean(v);


%% plot 
%sampleTheta = [0,pi/2,pi,4*pi/3,2*pi,5.2]; %for troubleshooting

x = [];
y =[];
figure;
for i = 1:length(ballData.data.ballHeadingDeg)               
    theta = ballData.data.ballHeadingRad(i);           
    vLength = length(ballData.data.ballHeadingRad); % vector size
    %i = 1:length(sampleTheta)
    %theta = sampleTheta(i);
    %vLength= (ones(length(sampleTheta),1));
    [x(i),y(i)] = pol2cart (theta,vLength);
    %compass(x,y);
    hold on;
end

xMean = mean(x);
yMean = mean(y);
compass(xMean,yMean);