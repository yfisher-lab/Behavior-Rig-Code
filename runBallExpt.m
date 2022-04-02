%runBallExpt
%
%
%
% Script for running fly on ball experiment using FicTrac and Reiser LED
% panels VR system
%
% Yvette Fisher 12/2021
%
clear all;

%% Experiment Parameters
USE_PANELS = true; %controls whether panels are used in trial (false -> off; true -> on)
USE_LED = false; %controls whether LED are used in trial (false -> off; true -> on)

% Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier.... 
%Panel_com()
panelParams.panelModeNum = [3, 0];
panelParams.patternNum = 1;
panelParams.initialPosition = [0, 0];

% Configure LED flashes
LEDParams.baselineTime = 900/1000; % initial time LED off in seconds
LEDParams.LEDonTime = 100/1000; % time LED on in seconds
LEDParams.afterTime = 4; % time LED off in seconds
LEDParams.REP_NUM = 12*10; % sum(LEDParams)*REP_NUM = 600 for 10 min trial;

% TODO - for non LED trials
fullTime = 10*60; % total duration in seconds

%% Start FicTrac in background from current experiment directory (config file must be in directory)
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

%% Run panels
if(USE_PANELS == 1)
    % keep inside if statemnet
    setUpClosedLoopPanelTrial(panelParams);    
    Panel_com('start');
end

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

%% Run LED

% create empty LED commmand array
LEDcommand = [];

highVoltage = 5; % V
dq.Rate = 1000;
dq_rate = dq.Rate;

if(USE_LED == 1)
    % Creating LED output
    LEDcommand = [zeros(LEDParams.baselineTime * dq.Rate , 1); highVoltage * ones(LEDParams.LEDonTime * dq.Rate, 1); zeros(LEDParams.afterTime * dq.Rate, 1)]; % LED on/off sequence matrix
    LEDcommand = repmat(LEDcommand,[LEDParams.REP_NUM,1]);
else
    % create empty LEDcommand
    LEDcommand = zeros(fullTime * dq.Rate, 1);
end

% Acquire timestamped data
data = readwrite(dq, LEDcommand);


if(USE_PANELS == 1)
    % Turn panels off
    Panel_com('stop');
    Panel_com('all_off'); % LEDs panel off
end

%% Save Data

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

if(USE_PANELS == 1)
    ballData.panelParams = panelParams;
end

if(USE_LED == 1)
    ballData.LEDParams = LEDParams;
end

% Save data  
%saveData ('C:\Users\fisherlab\Dropbox\Data\Menotaxis-MATC',ballData, 'Menotaxis_');
saveData('C:\Users\fisherlab\Dropbox\Data\TLN\Menotaxis',ballData, 'Menotaxis_');
%saveData ('C:\Users\fisherlab\Dropbox\Data\EPG_SPARC_JC',ballData, 'EPG_SPARC_');













