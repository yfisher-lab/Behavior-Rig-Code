function [  trialFilesList , fullTrialFilesList ] = extractTrialsFromFolder()
%EXTRACTTRIALSWITHCERTAINSTIMULUSNAME searches thru a folder with Ephy data
%from a single recording and extract all the trials that used a certain
%stimulus
%  INPUT
%       includeIfNameContainsString => Logical if 'true' any name that
%       contains the string will be returned.  If 'false' only exact string
%       matches will be return
%
%  OUTPUT
%       fullTrialNumberList => array containing all trial numbers where any
%       stimulus was used
%
%  Yvette Fisher 10/2017, updated Lily Nguyen 03/2022

% prompt users in a gui to navegate to the folder we want to analyize
DIRECTORYNAME = uigetdir();
cd( DIRECTORYNAME );

fileListDescription = fullfile(DIRECTORYNAME, '*.mat');
fileList = dir( fileListDescription );
% find which files contain the string 'trial'
isATrialLogical = contains( {fileList.name}, 'trial');
fileList = fileList( isATrialLogical ); % only keep files that are actually trial files


counter = 1;
allTrialsCounter = 1; % update the counter        

% loop over all data trials within that folder
for i = 1: length( fileList ) 
    % load current file
    load( fileList(i).name)

    % save current file name
    fullTrialFilesList(allTrialsCounter) = fileList(i);
    allTrialsCounter = allTrialsCounter + 1;

    % check if fileList is within trials wanted, if we are even bothering to check:
    if( exist( 'possibleTrialNums', 'var') )
        % if it is not correct trial number
        if( exist( 'trialMeta', 'var') && sum(trialMeta.trialNum == possibleTrialNums))
            % save file name into
            trialFilesList( counter ) = fileList (i);
            counter = counter + 1; % update the counter
        end
    else
         % save file name into
            trialFilesList( counter ) = fileList (i);
            counter = counter + 1; % update the counter          
    end  
end

%% Check if trialFilesList exists and if not create an empty variable and print warning
if( ~exist('trialFilesList') )
    trialFilesList = struct([]);
    print('WARNING: trialFilesList variable is empty, no files used')
end

end

