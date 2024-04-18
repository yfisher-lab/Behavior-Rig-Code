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

exptName = '15mClosedLoop'; % e.g., 30mClosedLoop 1hrClosedLoop
trialDuration = 30*60; % total duration in seconds (for non-LED trials)
flyNumber = 2; 
flyNotes = ...
    ["Laser off.";...
     "8-d-old female WT, housed in female-only vial since 1d.";...
     "Solo housed in vial w/ moist Kim-wipe for ~24h."];
%     ["8-d-old female wt. Moved to female-only vial at 1d";...
%      "Solo housed in vial w/ moist Kim-wipe for ~48h.";...
%      "New mounting strategy (sarcophagus flipped, forceps, no brush).";...
%      "Mounted on wire ~17:45. Loaded onto ball ~18:00.";...
%      "Displayed controlled forward walk before start of trial.";...
%      "Original ball. Airflow @300."];

daqRate = 20000; % Hz

% IMPORTANT: code won't work with LED and laser both set to 'true.'
USE_PANELS = true; % controls whether panels are used in trial (true = on)
USE_LASER = true; % controls whether 808nm laser is used in trial (true = on)
USE_LED = false; % controls whether LEDs are used in trial (true = on)

% Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier.... 
panelParams.panelModeNum = [3, 0];
panelParams.patternNum = 2;
panelParams.initialPosition = [48, 0]; %[4,6]

% Configure 808nm laser pulse width modulation settings:
laserParams.freq = 200; % Hz
laserParams.dutyCyc = 2; % percent, time(on)/(time(on)+time(off))
laserParams.delay = 15*60; % seconds
laserParams.dur = trialDuration - laserParams.delay; % seconds

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
cmdStr2 = ['cd "' Socket_PATH '" & py -3.10 ' SOCKET_SCRIPT_NAME ' &'];
[status] = system(cmdStr2, '-echo');


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
dq.Rate = daqRate;
addinput(dq,"Dev1", "ai0","Voltage"); % add analog input(AI) primary channel (xpos)
addinput(dq,"Dev1", "ai1","Voltage"); %add AI secondary channel (ball_heading/ yaw)
addinput(dq,"Dev1", "ai2","Voltage"); %add AI third channel (ball_heading/ xPos)
addinput(dq,"Dev1", "ai3","Voltage"); %add AI fourth channel (ball_heading/ yPos)

if USE_LASER == 1
    addoutput(dq, "Dev1", "port0/line0", 'Digital');
    write(dq, 0);
else
    addoutput(dq, "Dev1", "ao0", "Voltage");
end

dq.Channels(1).TerminalConfig = 'SingleEnded'; %save info that channel is in single ended on BOB 
dq.Channels(2).TerminalConfig = 'SingleEnded';
dq.Channels(3).TerminalConfig = 'SingleEnded';
dq.Channels(4).TerminalConfig = 'SingleEnded';


%% Make DAQ command array 'daqCommand.'

if USE_LASER == 1
    daqCommand = setUpLaserCommands(laserParams, dq);
elseif USE_LED == 1
    daqCommand = setUpLEDCommands(LEDParams, dq);
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


%% Shut down stuff.

if(USE_PANELS == 1)
    % Turn panels off
    Panel_com('stop');
    Panel_com('all_off'); % LEDs panel off
end

if USE_LASER == 1
    write(dq, 0);
    disp('Laser output [0]: Laser at lowest power.');
end

system('Taskkill/IM cmd.exe'); system('Taskkill /F /IM fictrac.exe');

disp('Saving...'); pause(4);


%% Save Data

ballData.data = data;
ballData.data.daqCommand = daqCommand;

ballData.data.Properties.VariableNames(1) = {'DAC0'};
ballData.data.Properties.VariableNames(2) = {'PhidgetCh0'};
ballData.data.Properties.VariableNames(3) = {'PhidgetCh1'};
ballData.data.Properties.VariableNames(4) = {'PhidgetCh2'};

ballData.data4python = table2array(ballData.data);

[ballData.ficTracLog, ballData.ficTFilename] = getLatestFicTracLog();

ballData.dqRate = dq.Rate;
ballData.timeOfExpt = timeOfExpt;
ballData.notes = flyNotes;

if(USE_PANELS == 1)
    ballData.panelParams = panelParams;
end

if(USE_LASER == 1)
    ballData.laserParams = laserParams;
end

if(USE_LED == 1)
    ballData.LEDParams = LEDParams;
end

% ballData.data = data;
% ballData.data.DAC0 = data.Dev1_ai0;
% ballData.data.PhidgetCh0 = data.Dev1_ai1;
% ballData.data.PhidgetCh1 = data.Dev1_ai2;
% ballData.data.PhidgetCh2 = data.Dev1_ai3;
%
% % Store ball heading and panel position values in mV
% bar_xPos = (data.Dev1_ai0); % DAC0 output from controller gives bar x-pos
% ball_heading = (data.Dev1_ai1); % phidget output Ch0 [yaw]
% ball_xPos = (data.Dev1_ai2); % phidget output Ch1 [x-pos/pitch]
% ball_yPos = (data.Dev1_ai3); % phidget output Ch2 [y-pos/roll]
% 
% % Change V to angle (degrees)
% bar_xPos = (bar_xPos) * 360 / 10; % V to degrees
% ball_headingDeg = (ball_heading) * 360 / 10;
% ball_xPos = (ball_xPos) * 360 / 10;
% ball_yPos = (ball_yPos) * 360 / 10;
% 
% ballData.data.barXPos = bar_xPos;
% ballData.data.ballHeading = ball_headingDeg;
% ballData.data.ballXPos = ball_xPos;
% ballData.data.ballYPos = ball_yPos;

ballData.dqRate = dq.Rate;
ballData.timeOfExpt = timeOfExpt;
ballData.notes = flyNotes;

F = whos('ballData');
if F.bytes > 2000000000
    ballData.data = downsampleBallData(ballData.data, dq.Rate, 10000);
    ballData.data4python = table2array(ballData.data);
    ballData.downSampledRate = 10000;
end

saveData('C:\Users\fisherlab\Documents\AJH-arena-data',...
             ballData, exptName, flyNumber);

disp('Done!');

