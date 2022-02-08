%runBallExpt
%
%
%
% Script for running fly on ball expeirment using FicTrac and Reiser LED
% panels VR system
%
% Yvette Fisher 12/2021
%
clear all;
% Start FicTrac in background from current experiment directory (config file must be in directory)
FT_PATH = 'C:\Users\fisherlab\Documents\GitHub\ficTrac\';
FT_EXE_FILENAME = 'fictrac.exe';
cmdStr = ['cd "', FT_PATH, '" ', '& start ', FT_PATH, FT_EXE_FILENAME];
system(cmdStr);
pause(4);

% Call socket_client_360 to open socket connection from fictrac to Phiget22 device
% to edit socket_client_360 you can use PyCharm Edu
Socket_PATH = 'C:\Users\fisherlab\Documents\GitHub\Behavior-Rig-Code\';
SOCKET_SCRIPT_NAME = 'socket_client_360.py';
%cmdstring = ['cd "' Socket_PATH '" & python ' SOCKET_SCRIPT_NAME ' &'];
cmdstring = ['cd "' Socket_PATH '" & py ' SOCKET_SCRIPT_NAME ' &'];
[status] = system(cmdstring, '-echo');

%% TODO - Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier....
panelParams.panelModeNum = [3, 0];
panelParams.patternNum = 1;
panelParams.initialPosition = [0, 6];
setUpClosedLoopPanelTrial(panelParams);
Panel_com('start');


%% Recording the data!!!
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
% Fictrac ball heading (0-10V)
% Panel pattern postion (x pos)

%Set NI (terminal block) config
%d = daqlist;  %see NI devices connected to computer
%d(1, :)
%d{1, "DeviceInfo"}  %see NI device info 

% Setup data acquisition session (daq)
dq = daq("ni"); %create data acquisition object
addinput(dq,"Dev1", "ai0","Voltage"); % add analog input(AI) primary channel (xpos)
addinput(dq,"Dev1", "ai1","Voltage"); %add AI secondary channel (ball_heading)
addoutput(dq, "Dev1", "ao0", "Voltage") %add AO primary channel (LED)


dq.Channels(1).TerminalConfig = 'SingleEnded'; %save info that channel is in single ended on BOB 
dq.Channels(2).TerminalConfig = 'SingleEnded';

baselineTime = 1; %initial time LED off
LEDonTime = 4*60; %time LED on in min
afterTime = 2*60;%time LED off in min
fullTime = 10*60; 
highVoltage = 5; % V
dq.Rate = 1000;
dq_rate = dq.Rate;

% Creating LED output
%LEDcommand = [zeros(baselineTime * dq.Rate , 1); highVoltage * ones(LEDonTime * dq.Rate, 1); zeros(afterTime * dq.Rate, 1)]; % LED on/off sequence matrix

LEDcommand = zeros(fullTime * dq.Rate , 1); %running w/o LED cycle

% Acquire timestamped data
data = readwrite(dq, LEDcommand);
Panel_com('stop');
Panel_com('all_off'); % LEDs panel off

% Store ball heading and panel position (x_pos) values in mV
x_pos = (data.Dev1_ai0); % DAC0 output from controller gives x frame 
ball_heading = (data.Dev1_ai1); % phidget output 

% change V to angle
x_posRad = (x_pos) * (2 *pi) / 10;
ball_headingRad = (ball_heading) * (2 *pi) / 10;

x_posDeg = (x_pos) * 360 / 10;
ball_headingDeg = (ball_heading) * 360 / 10;

% create larger struct for all data and recording conditions
ballData.data = data;
ballData.data.x_posDeg = x_posDeg;
ballData.data.ballHeadingDeg = ball_headingDeg;
ballData.data.x_posRad = x_posRad;
ballData.data.ballHeadingRad = ball_headingRad;
ballData.dqRate = dq_rate;
ballData.data.LEDcommand = LEDcommand;
if(exist("panelParams",'var'))
    ballData.panelParams = panelParams;
end

% Save data  
saveData ('C:\Users\fisherlab\Documents\GitHub\Behavior-Rig-Code\Data\Menotaxis-MATC\',ballData, 'Menotaxis_');

%% Plot data

% Import file with data to plot
%importfile('Menotaxis_220204_trial_1') 

% %% Plot data
figure;
plot( [1:1:length(LEDcommand)]/dq.Rate ,ball_heading);
%hold on;
figure;
plot( [1:1:length(LEDcommand)]/dq.Rate ,x_pos);
%max(ball_heading)

% histogram - to check if results are random vs. she's actually menotaxing
figure;
hist.plot = histogram(ball_heading);











