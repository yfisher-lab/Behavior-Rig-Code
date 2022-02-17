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
%Panel_com()
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
addinput(dq,"Dev1", "ai1","Voltage"); %add AI secondary channel (ball_heading/ yaw)
addinput(dq,"Dev1", "ai2","Voltage"); %add AI third channel (ball_heading/ xPos)
addinput(dq,"Dev1", "ai3","Voltage"); %add AI fourth channel (ball_heading/ yPos)
addoutput(dq, "Dev1", "ao0", "Voltage"); %add AO primary channel (LED)


dq.Channels(1).TerminalConfig = 'SingleEnded'; %save info that channel is in single ended on BOB 
dq.Channels(2).TerminalConfig = 'SingleEnded';
dq.Channels(3).TerminalConfig = 'SingleEnded';
dq.Channels(4).TerminalConfig = 'SingleEnded';

% create empty LED commmand array
LEDcommand = [];

% for LED flash trials
baselineTime = 400/1000; %initial time LED off in ms
LEDonTime = 100/1000; %time LED on in milisecond
afterTime = 500/1000;%time LED off in milisecond
REP_NUM = 60*10;

% for non LED trials
fullTime = 10*60; 

highVoltage = 5; % V
dq.Rate = 1000;
dq_rate = dq.Rate;

% Creating LED output
%LEDcommand = [zeros(baselineTime * dq.Rate , 1); highVoltage * ones(LEDonTime * dq.Rate, 1); zeros(afterTime * dq.Rate, 1)]; % LED on/off sequence matrix
%LEDcommand = repmat(LEDcommand,[REP_NUM,1]);

LEDcommand = zeros(fullTime * dq.Rate , 1); %running w/o LED cycle

% Acquire timestamped data
data = readwrite(dq, LEDcommand);

% Turn panels off
Panel_com('stop');
Panel_com('all_off'); % LEDs panel off

% Save Data

% Store ball heading and panel position (x_pos) values in mV
x_pos = (data.Dev1_ai0); % DAC0 output from controller gives x frame 
ball_heading = (data.Dev1_ai1); % phidget output 
ball_xPos = (data.Dev1_ai2); % phidget output 
ball_yPos = (data.Dev1_ai3); % phidget output 

% change V to angle
x_posRad = (x_pos) * (2 *pi) / 10;  % V to radians
ball_headingRad = (ball_heading) * (2 *pi) / 10;

x_posDeg = (x_pos) * 360 / 10;    % V to degrees
ball_headingDeg = (ball_heading) * 360 / 10;

ball_xPos = (ball_xPos) * 360 / 10;
ball_yPos = (ball_yPos) * 360 / 10;

% create larger struct for all data and recording conditions
ballData.data = data;
ballData.data.x_posDeg = x_posDeg;
ballData.data.ballHeadingDeg = ball_headingDeg;
ballData.data.ballxPosDeg = ball_xPos;
ballData.data.ballyPosDeg = ball_yPos;
ballData.data.x_posRad = x_posRad;
ballData.data.ballHeadingRad = ball_headingRad;
ballData.dqRate = dq_rate;
ballData.data.LEDcommand = LEDcommand;
if(exist("panelParams",'var'))
    ballData.panelParams = panelParams;
end

% Save data  
saveData ('C:\Users\fisherlab\Documents\GitHub\Behavior-Rig-Code\Data\Menotaxis-MATC\',ballData, 'Menotaxis_');
%saveData ('C:\Users\fisherlab\Documents\GitHub\Behavior-Rig-Code\Data\EPG_SPARC_JC\',ballData, 'EPG_SPARC_');











