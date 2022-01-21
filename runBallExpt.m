%runBallExpt
%
%
%
% Script for running fly on ball expeirment using FicTrac and Reiser LED
% panels VR system
%
% Yvette Fisher 12/2021


% TODO - Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier....
%panelParams.panelModeNum = [3, 0];
%panelParams.patternNum = 1;
%setUpClosedLoopPanelTrial(panelParams);
% MATC moved script to the bottom 222101

%

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

% TODO - Configure panels, for closed loop mode and set up which pattern to use
% and set up external tiggering if you want things to
% start with a trigger, or just have the pattern start if that is
% easier....
panelParams.panelModeNum = [3, 0];
panelParams.patternNum = 1;
MATCsetUpClosedLoopPanelTrial(panelParams);