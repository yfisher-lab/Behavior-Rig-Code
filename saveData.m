function [] = saveData( directory , ballData, expName, flyNumberIn)
%SAVEDATA
% INPUT
%       directory - location where the data should be saved
%       ballData - data to be saved in that location
%       expName - experiment name/ type, e.g. 'Menotaxis'
%       flyNumberIn - fly ID (for multiple trials w/ same fly on the same day)
%
% The data will be saved as %'BallData_YYMMDD_trial_##'
% where YY== year, MM = month, DD= day and ## is the next trial that
% doesn't yet exist in that folder for that date
%
% Yvette Fisher and Jessica Co 2/2022
% Andrew added 'flyNumber' modifications 1/2024

% make date number string
format = 'yymmdd';  %YYMMDD format
flyNum = num2str(flyNumberIn);
fileNamePrefix = [ datestr(now, format) '_' expName '_fly' flyNum ];

% navigate to data directory
cd(directory)

%Check how many .mat files contain fileNamePrefix
fileList = dir(fullfile(directory,'*.mat'));

counter = 1;
for i = 1:length(fileList)

    currFile = fileList(i);
    if( contains(currFile.name, fileNamePrefix) )
        counter = counter + 1;
    end
end

fullFileName = [fileNamePrefix '_trial' num2str(counter)];
% e.g. 'BallData_161014_trial#'

%save your variable with the full file name
save(fullFileName, 'ballData')

end