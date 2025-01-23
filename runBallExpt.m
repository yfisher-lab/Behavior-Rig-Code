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

exptName = '30mBrightBar-wLED-100msQ30s-PanelsOFF'; % e.g., 30mClosedLoop 1hrClosedLoop
trialDuration = 30*60; % total duration in seconds (for non-LED trials)
flyNumber = 4;
%flyGenotype = 'w+; +; + (isoD1)';
flyGenotype = 'ExR6 > CsChrimson';
%flyGenotype = '+; +; UAS-Kir2.1/+';
%flyGenotype = 'w+/; EPG-AD/+; EPG-DBD/+ (SS00096)';
%flyGenotype = 'w+/; EPG-AD/+; EPG-DBD/UAS-Kir2.1 (SS00096)';
%flyGenotype = 'w+/; EL-AD/UAS-TBH-RNAi; EL-DBD/+ (67968)';
%flyGenotype = 'w+/; UAS-TBH-RNAi/+; + (67968)';
%flyGenotype = 'w+/; EL-AD/+; EL-DBD/+';
flyNotes = ...
    ["Female, 6-7 days old.";...
     "Housed in female-only vial since 1 days old.";...
     "Solo housed in vial w/ moist Kim-wipe for ~18 h."];

trialType = 4;

if trialType == 1 % Panels ON, laser/LED OFF.
    USE_PANELS = true;
    USE_LASER = false;
    USE_LED = false; % Code currently won't work w/ LED & LASER both set to 'true'.

elseif trialType == 2 % Panels ON, laser ON.
    USE_PANELS = true;
    USE_LASER = true;
    USE_LED = false; % Code currently won't work w/ LED & LASER both set to 'true'.

elseif trialType == 3 % Panels OFF, laser ON.
    USE_PANELS = false;
    USE_LASER = true;
    USE_LED = false;

elseif trialType == 4 % Panels ON, LED ON.
    USE_PANELS = true;
    USE_LASER = false;
    USE_LED = true;

elseif trialType == 5 % Panels OFF, LED ON.
    USE_PANELS = false;
    USE_LASER = false;
    USE_LED = true;

end

daqRate = 10000; % Hz

% Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier.... 
panelParams.panelModeNum = [3, 0];
panelParams.patternNum = 7;
panelParams.initialPosition = [0, 0]; %[44, 0]; %[4, 6] [44, 2]

% Configure 850nm laser pulse width modulation settings:
laserParams.freq = 200; % Hz
laserParams.dutyCyc = 8; % percent, time(on)/(time(on)+time(off))
laserParams.delay = 5; % seconds
laserParams.dur = trialDuration - laserParams.delay; % seconds

% Configure LED flashes
LEDParams.delay = 900; % (seconds)
LEDParams.LEDOnTime = 1; % 0.1 % time LED on (seconds)
LEDParams.LEDPulseOnTime = 0.1; % 0.05
LEDParams.LEDPulseOffTime = 0.9; % 0.05
LEDParams.interStimDur = 29;
LEDParams.dur = trialDuration - LEDParams.delay; % (seconds)

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
    write(dq, 1);
else
    addoutput(dq, "Dev1", "ao0", "Voltage");
end

dq.Channels(1).TerminalConfig = 'SingleEnded'; %save info that channel is in single ended on BOB 
dq.Channels(2).TerminalConfig = 'SingleEnded';
dq.Channels(3).TerminalConfig = 'SingleEnded';
dq.Channels(4).TerminalConfig = 'SingleEnded';


%% Make DAQ command array 'daqCommand.'

if USE_LASER == 1
    daqCommand = setUpLaserCommands(laserParams, dq.Rate);
elseif USE_LED == 1
    daqCommand = setUpLEDCommands(LEDParams, dq.Rate);
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
    write(dq, 1);
    disp('Laser output [1]: Laser off.');
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

%ballData.data4python = table2array(ballData.data);

[ballData.ficTracLog, ballData.ficTFilename] = getLatestFicTracLog();

ballData.dqRate = dq.Rate;
ballData.timeOfExpt = timeOfExpt;
ballData.flyGenotype = flyGenotype;
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


F = whos('ballData');
if F.bytes > 2000000000
    disp("ballData too large to save (>2GB)... Downsampling...");
    ballData.data = downsampleBallData(ballData.data, dq.Rate, 10000);
    %ballData.data4python = table2array(ballData.data);
    ballData.downSampledRate = 10000;
end

saveData('C:\Users\fisherlab\Documents\AJH-arena-data',...
             ballData, exptName, flyNumber);

disp('Done!');


%%

figure; plot(ballData.ficTracLog.Var15, ballData.ficTracLog.Var16);
axis equal