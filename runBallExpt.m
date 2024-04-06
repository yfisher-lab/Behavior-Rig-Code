%runBallExpt
%
%
%
% Script for running fly on ball experiment using FicTrac and Reiser LED
% panels VR system
%
% Yvette Fisher 12/2021
%
clear all; close all;

%% Experiment Parameters

exptName = '30mClosedLoop'; %Pre-trial %30mClosedLoop %1hrClosedLoop
trialDuration = 30*60; % total duration in seconds (for non-LED trials)
flyNumber = 2; 
flyNotes = ...
    ["5-d-old female R4d-kir2.1. Moved to female-only vial at 1d";...
     "Solo housed in vial w/ moist Kim-wipe for ~48h.";...
     "New mounting strategy (sarcophagus flipped, forceps, no brush).";...
     "Mounted on wire ~15:00. Loaded onto ball ~15:15.";...
     "Displayed controlled forward walk before start of trial.";...
     "Original ball. Airflow @300."];


USE_PANELS = true; %controls whether panels are used in trial (false -> off; true -> on)
USE_LED = false; %controls whether LED are used in trial (false -> off; true -> on)

% Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier.... 
%Panel_com()
panelParams.panelModeNum = [3, 0];
panelParams.patternNum = 2;
panelParams.initialPosition = [48, 0]; %[4,6]

% Configure LED flashes
LEDParams.baselineTime = 0; % initial time LED off in seconds
LEDParams.LEDonTime = 0.1; % time LED on in seconds
LEDParams.afterTime = 0.1; % time LED off in seconds
LEDParams.REP_NUM = 10000; % sum(LEDParams)*REP_NUM = 600 for 10 min trial;

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
cmdstring = ['cd "' Socket_PATH '" & py -3.10 ' SOCKET_SCRIPT_NAME ' &'];
[status] = system(cmdstring, '-echo');

%% Run panels

if(USE_PANELS == 1)
    % keep inside if statemnet
    setUpClosedLoopPanelTrial(panelParams);    
    Panel_com('start');
end

%% Set up DAQ
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
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

%% Make DAQ command array 'daqCommand'

daqCommand = [];
highVoltage = 5;
dq.Rate = 1000;

if(USE_LED == 1)
    daqCommand = setUpLEDCommands(LEDParams, dq, highVoltage);
else
    daqCommand = zeros(trialDuration * dq.Rate, 1);
end

% if(USE_LED == 1)
%     % Creating LED output
%     LEDcommand = [zeros(LEDParams.baselineTime * dq.Rate , 1); highVoltage * ones(LEDParams.LEDonTime * dq.Rate, 1); zeros(LEDParams.afterTime * dq.Rate, 1)]; % LED on/off sequence matrix
%     LEDcommand = repmat(LEDcommand,[LEDParams.REP_NUM,1]);
% else
%     % create empty LEDcommand
%     LEDcommand = zeros(trialDuration * dq.Rate, 1);
% end

%% Get timestamped data from, and send commands to, DAQ.

% Acquire timestamped data
timeOfExpt = now;
timeOfExpt = datetime(timeOfExpt, 'ConvertFrom', 'datenum');
disp(timeOfExpt);

data = readwrite(dq, daqCommand);

if(USE_PANELS == 1)
    % Turn panels off
    Panel_com('stop');
    Panel_com('all_off'); % LEDs panel off
end

%% Save Data

ballData.data = data;
ballData.data.DAC0 = data.Dev1_ai0;
ballData.data.PhidgetCh0 = data.Dev1_ai1;
ballData.data.PhidgetCh1 = data.Dev1_ai2;
ballData.data.PhidgetCh2 = data.Dev1_ai3;
ballData.data.daqCommand = daqCommand;

ballData.dqRate = dq.Rate;
ballData.timeOfExpt = timeOfExpt;
ballData.notes = flyNotes;

if(USE_PANELS == 1)
    ballData.panelParams = panelParams;
end

if(USE_LED == 1)
    ballData.LEDParams = LEDParams;
end

% Store ball heading and panel position values in mV
bar_xPos = (data.Dev1_ai0); % DAC0 output from controller gives bar x-pos
ball_heading = (data.Dev1_ai1); % phidget output Ch0 [yaw]
ball_xPos = (data.Dev1_ai2); % phidget output Ch1 [x-pos/pitch]
ball_yPos = (data.Dev1_ai3); % phidget output Ch2 [y-pos/roll]

% Change V to angle (degrees)
bar_xPos = (bar_xPos) * 360 / 10; % V to degrees
ball_headingDeg = (ball_heading) * 360 / 10;
ball_xPos = (ball_xPos) * 360 / 10;
ball_yPos = (ball_yPos) * 360 / 10;

ballData.data.barXPos = bar_xPos;
ballData.data.ballHeading = ball_headingDeg;
ballData.data.ballXPos = ball_xPos;
ballData.data.ballYPos = ball_yPos;

% % Change V to angle (radians)
% bar_xPosRad = (bar_xPos) * (2*pi) / 10;  % V to radians
% ball_headingRad = (ball_heading) * (2 *pi) / 10;
% ballData.data.barXPos_rad = bar_xPosRad;
% ballData.data.ballHeading_rad = ball_headingRad;

ballData.data4python = table2array(ballData.data);

saveData('C:\Users\fisherlab\Documents\AJH-arena-data',...
             ballData, exptName, flyNumber);


%%

% saveData ('C:\Users\fisherlab\Dropbox\Data\Menotaxis-MATC',ballData, 'Menotaxis_');
% saveData('C:\Users\fisherlab\Dropbox\Data\TLN\Menotaxis',ballData, 'Menotaxis_');
% saveData ('C:\Users\fisherlab\Dropbox\Data\EPG_SPARC_JC',ballData, 'EPG_SPARC_');
