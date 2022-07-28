clear all;
% Import file with data to plot
file = 'Menotaxis_220310_trial_20';
importfile(file)

%% Plot data in sec 
figure;
plot( [1:1:length(ballData.data.ballHeadingDeg)]/ballData.dqRate ,ballData.data.ballHeadingDeg);
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
figure;
plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballHeadingDeg);
title(file,'Interpreter','none');
xlabel('Time (min)');
ylabel('Ball Heading (deg)');

figure;
plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballxPosDeg);
title(file,'Interpreter','none');
xlabel('Time (min)');
ylabel('Ball X-Position (deg)');

figure;
plot( [1:1:length(ballData.data.LEDcommand)]/(60*ballData.dqRate) ,ballData.data.ballyPosDeg);
title(file,'Interpreter','none');
xlabel('Time (min)');
ylabel('Ball Y-Position (deg)');


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



    

